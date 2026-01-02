type Task<T> = () => Promise<T>;

class PdfRenderQueue {
  private queue: Task<any>[] = [];
  private running = false;

  enqueue<T>(task: Task<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await task();
          resolve(result);
        } catch (err) {
          reject(err);
        }
      });

      this.run();
    });
  }

  private async run() {
    if (this.running) return;
    this.running = true;

    while (this.queue.length > 0) {
      const task = this.queue.shift();
      if (!task) continue;
      await task();
    }

    this.running = false;
  }

  clear() {
    this.queue = [];
  }
}

export const pdfRenderQueue = new PdfRenderQueue();
