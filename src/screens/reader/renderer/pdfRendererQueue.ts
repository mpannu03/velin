type Task<T> = () => Promise<T>;

type QueueTask<T> = {
  task: Task<T>;
  priority: number; // Higher = more important
  resolve: (value: T) => void;
  reject: (reason: any) => void;
  signal?: AbortSignal;
  key?: string; // Cache key for priority escalation
};

class PdfRenderQueue {
  private queue: QueueTask<any>[] = [];
  private pendingTasks = new Map<string, Promise<any>>();
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
    // 🚀 Priority Escalation: If task already pending and still in queue, bump its priority
    if (key && this.pendingTasks.has(key)) {
      const existingInQueue = this.queue.find((t) => t.key === key);
      if (existingInQueue && priority > existingInQueue.priority) {
        existingInQueue.priority = priority;
        // ⚡ Optimization: Only sort if priority actually changed
        this.queue.sort((a, b) => b.priority - a.priority);
      }
      return this.pendingTasks.get(key)!;
    }

    const promise = new Promise<T>((resolve, reject) => {
      // If already aborted, reject immediately
      if (signal?.aborted) {
        Promise.resolve().then(() => reject(new Error("Aborted")));
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

      // Insert task in priority order (higher priority first)
      let inserted = false;
      for (let i = 0; i < this.queue.length; i++) {
        if (queueTask.priority > this.queue[i].priority) {
          this.queue.splice(i, 0, queueTask);
          inserted = true;
          break;
        }
      }

      if (!inserted) {
        this.queue.push(queueTask);
      }
    });

    if (key) {
      this.pendingTasks.set(key, promise);
      promise.finally(() => this.pendingTasks.delete(key)).catch(() => {});
    }

    this.runNext();
    return promise;
  }

  private runNext() {
    while (this.runningCount < this.maxConcurrent && this.queue.length > 0) {
      const queueTask = this.queue.shift();
      if (!queueTask) return;

      // Skip aborted tasks
      if (queueTask.signal?.aborted) {
        Promise.resolve().then(() => queueTask.reject(new Error("Aborted")));
        continue;
      }

      this.runningCount++;

      queueTask
        .task()
        .then((result) => {
          queueTask.resolve(result);
        })
        .catch((err) => {
          queueTask.reject(err);
        })
        .finally(() => {
          this.runningCount--;
          this.runNext();
        });
    }
  }

  clear() {
    this.queue = [];
    this.pendingTasks.clear();
  }

  cancelLowerPriority(minPriority: number) {
    const remaining: QueueTask<any>[] = [];
    const cancelled: QueueTask<any>[] = [];

    for (const task of this.queue) {
      if (task.priority >= minPriority) {
        remaining.push(task);
      } else {
        cancelled.push(task);
      }
    }

    this.queue = remaining;

    for (const task of cancelled) {
      Promise.resolve().then(() => task.reject(new Error("Aborted")));
    }
  }
}

export const pdfRenderQueue = new PdfRenderQueue(6);
