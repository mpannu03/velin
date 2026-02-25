type Task<T> = () => Promise<T>;

type QueueTask<T> = {
  task: Task<T>;
  priority: number; // Higher = more important
  resolve: (value: T) => void;
  reject: (reason: any) => void;
  signal?: AbortSignal;
};

class PdfRenderQueue {
  private queue: QueueTask<any>[] = [];
  private runningCount = 0;
  private readonly maxConcurrent: number;

  constructor(maxConcurrent = 2) {
    this.maxConcurrent = maxConcurrent;
  }

  enqueue<T>(
    task: Task<T>,
    signal?: AbortSignal,
    priority: number = 0,
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      // If already aborted, reject immediately
      if (signal?.aborted) {
        return reject(new Error("Aborted"));
      }

      const queueTask: QueueTask<T> = {
        task,
        priority,
        resolve,
        reject,
        signal,
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

      this.runNext();
    });
  }

  private runNext() {
    while (this.runningCount < this.maxConcurrent && this.queue.length > 0) {
      const queueTask = this.queue.shift();
      if (!queueTask) return;

      // Skip aborted tasks
      if (queueTask.signal?.aborted) {
        queueTask.reject(new Error("Aborted"));
        continue;
      }

      this.runningCount++;

      queueTask
        .task()
        .then((result) => {
          if (!queueTask.signal?.aborted) {
            queueTask.resolve(result);
          }
        })
        .catch((err) => {
          if (!queueTask.signal?.aborted) {
            queueTask.reject(err);
          }
        })
        .finally(() => {
          this.runningCount--;
          this.runNext();
        });
    }
  }

  clear() {
    this.queue = [];
  }

  // Cancel all pending tasks with lower priority
  cancelLowerPriority(minPriority: number) {
    this.queue = this.queue.filter((task) => task.priority >= minPriority);
  }
}

export const pdfRenderQueue = new PdfRenderQueue(2);
