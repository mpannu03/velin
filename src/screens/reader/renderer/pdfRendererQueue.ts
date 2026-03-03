type Task<T> = () => Promise<T>;

type QueueTask<T> = {
  task: Task<T>;
  priority: number;
  resolve: (value: T) => void;
  reject: (reason: any) => void;
  signal?: AbortSignal;
  key?: string;
};

class PdfRenderQueue {
  private queue: QueueTask<any>[] = [];

  private pendingTasks = new Map<string, Promise<any>>();

  private queuedByKey = new Map<string, QueueTask<any>>();

  private runningCount = 0;
  private readonly maxConcurrent: number;

  constructor(maxConcurrent = 6) {
    this.maxConcurrent = maxConcurrent;
  }

  enqueue<T>(
    task: Task<T>,
    signal?: AbortSignal,
    priority: number = 0,
    key?: string,
  ): Promise<T> {
    console.log(key, priority);
    if (key) {
      const existingPromise = this.pendingTasks.get(key);
      if (existingPromise) {
        const queuedTask = this.queuedByKey.get(key);

        if (queuedTask && priority > queuedTask.priority) {
          queuedTask.priority = priority;
          this.queue.sort((a, b) => b.priority - a.priority);
        }

        return existingPromise;
      }
    }

    const promise = new Promise<T>((resolve, reject) => {
      if (signal?.aborted) {
        reject(new Error("Aborted"));
        return;
      }

      const queueTask: QueueTask<T> = {
        task,
        priority,
        resolve,
        reject,
        signal,
        key,
      };

      let inserted = false;

      for (let i = 0; i < this.queue.length; i++) {
        if (priority > this.queue[i].priority) {
          this.queue.splice(i, 0, queueTask);
          inserted = true;
          break;
        }
      }

      if (!inserted) {
        this.queue.push(queueTask);
      }

      if (key) {
        this.queuedByKey.set(key, queueTask);
      }
    });

    if (key) {
      this.pendingTasks.set(key, promise);

      promise
        .finally(() => {
          this.pendingTasks.delete(key);
        })
        .catch(() => {});
    }

    this.runNext();

    return promise;
  }

  private runNext() {
    while (this.runningCount < this.maxConcurrent && this.queue.length > 0) {
      const queueTask = this.queue.shift();
      if (!queueTask) return;

      if (queueTask.key) {
        this.queuedByKey.delete(queueTask.key);
      }

      if (queueTask.signal?.aborted) {
        queueTask.reject(new Error("Aborted"));
        continue;
      }

      this.runningCount++;

      queueTask
        .task()
        .then(queueTask.resolve)
        .catch(queueTask.reject)
        .finally(() => {
          this.runningCount--;
          this.runNext();
        });
    }
  }

  clear() {
    const tasks = [...this.queue];

    this.queue = [];
    this.queuedByKey.clear();
    this.pendingTasks.clear();

    for (const t of tasks) {
      t.reject(new Error("Aborted"));
    }
  }

  cancelLowerPriority(minPriority: number) {
    const remaining: QueueTask<any>[] = [];

    for (const task of this.queue) {
      if (task.priority >= minPriority) {
        remaining.push(task);
      } else {
        if (task.key) {
          this.queuedByKey.delete(task.key);
        }
        task.reject(new Error("Aborted"));
      }
    }

    this.queue = remaining;
  }
}

export const pdfRenderQueue = new PdfRenderQueue(6);
