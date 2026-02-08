type Task<T> = () => Promise<T>;

class PdfRenderQueue {
  private queue: Task<any>[] = [];
  private runningCount = 0;
  private readonly maxConcurrent: number;

  constructor(maxConcurrent = 2) {
    this.maxConcurrent = maxConcurrent;
  }

  enqueue<T>(task: Task<T>, signal?: AbortSignal): Promise<T> {
    return new Promise((resolve, reject) => {
      // If already aborted, reject immediately
      if (signal?.aborted) {
        return reject(new Error('Aborted'));
      }

      const queueItem = async () => {
        if (signal?.aborted) {
          this.runningCount--;
          this.runNext();
          return;
        }
        try {
          const result = await task();
          resolve(result);
        } catch (err) {
          reject(err);
        } finally {
          this.runningCount--;
          this.runNext();
        }
      };

      this.queue.push(queueItem);
      this.runNext();
    });
  }

  private runNext() {
    while (
      this.runningCount < this.maxConcurrent &&
      this.queue.length > 0
    ) {
      const task = this.queue.shift();
      if (!task) return;

      this.runningCount++;
      task();
    }
  }

  clear() {
    this.queue = [];
  }
}

export const pdfRenderQueue = new PdfRenderQueue(3);
