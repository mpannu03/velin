import fs from "fs-extra";
import path from "path";
import { fileURLToPath } from "url";
import https from "https";
import http from "http";
import { extract } from "tar";
import AdmZip from "adm-zip";
import os from "os";
import chalk from "chalk";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const PDFIUM_VERSION = "7543";
const BASE_URL = `https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F${PDFIUM_VERSION}`;

interface PlatformConfig {
  target: string;
  pdfiumArchive: string;
  binaryName: string;
}

const PLATFORM_MAPPINGS: Record<string, PlatformConfig> = {
  "x86_64-pc-windows-msvc": {
    target: "x86_64-pc-windows-msvc",
    pdfiumArchive: "pdfium-win-x64.tgz",
    binaryName: "pdfium.dll",
  },
  "x86_64-apple-darwin": {
    target: "x86_64-apple-darwin",
    pdfiumArchive: "pdfium-mac-x64.tgz",
    binaryName: "libpdfium.dylib",
  },
  "aarch64-apple-darwin": {
    target: "aarch64-apple-darwin",
    pdfiumArchive: "pdfium-mac-arm64.tgz",
    binaryName: "libpdfium.dylib",
  },

  "x86_64-unknown-linux-gnu": {
    target: "x86_64-unknown-linux-gnu",
    pdfiumArchive: "pdfium-linux-x64.tgz",
    binaryName: "libpdfium.so",
  },
};

function getCurrentTarget(): string {
  const platform = os.platform();
  const arch = os.arch();

  switch (platform) {
    case "win32":
      if (arch === "x64") return "x86_64-pc-windows-msvc";
      break;

    case "darwin":
      if (arch === "x64") return "x86_64-apple-darwin";
      if (arch === "arm64") return "aarch64-apple-darwin";
      break;

    case "linux":
      if (arch === "x64") return "x86_64-unknown-linux-gnu";
      break;
  }

  throw new Error(`Unsupported platform: ${platform}-${arch}`);
}

async function downloadFile(url: string, outputPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith("https") ? https : http;

    const request = protocol.get(url, (response) => {
      if (
        response.statusCode === 301 ||
        response.statusCode === 302 ||
        response.statusCode === 307
      ) {
        if (response.headers.location) {
          console.log(
            chalk.gray(`  Redirecting to ${response.headers.location}`),
          );
          downloadFile(response.headers.location, outputPath)
            .then(resolve)
            .catch(reject);
          return;
        }
      }

      if (response.statusCode !== 200) {
        reject(new Error(`Download failed: ${response.statusCode}`));
        return;
      }

      const file = fs.createWriteStream(outputPath);

      const timeout = setTimeout(() => {
        request.destroy();
        reject(new Error("Download timeout"));
      }, 30000);

      response.pipe(file);

      file.on("finish", () => {
        clearTimeout(timeout);
        file.close();
        resolve();
      });

      file.on("error", (err) => {
        clearTimeout(timeout);
        fs.unlink(outputPath).catch(() => {});
        reject(err);
      });
    });

    request.on("error", (err) => {
      fs.unlink(outputPath).catch(() => {});
      reject(err);
    });
  });
}

async function extractArchive(archivePath: string, extractPath: string) {
  await fs.ensureDir(extractPath);

  if (archivePath.endsWith(".zip")) {
    const zip = new AdmZip(archivePath);
    zip.extractAllTo(extractPath, true);
  } else {
    await extract({
      file: archivePath,
      cwd: extractPath,
    });
  }
}

async function findBinary(
  extractPath: string,
  binaryName: string,
): Promise<string> {
  const paths = [
    path.join(extractPath, binaryName),
    path.join(extractPath, "bin", binaryName),
    path.join(extractPath, "lib", binaryName),
  ];

  for (const p of paths) {
    if (await fs.pathExists(p)) {
      return p;
    }
  }

  throw new Error(`Binary ${binaryName} not found after extraction`);
}

async function downloadPdfiumForTarget(target: string) {
  const config = PLATFORM_MAPPINGS[target];

  if (!config) {
    console.log(chalk.yellow(`No mapping for ${target}`));
    return;
  }

  const resourcesDir = path.join(__dirname, "../src-tauri/resources");
  const targetDir = path.join(resourcesDir, target);

  await fs.ensureDir(targetDir);

  const targetBinaryPath = path.join(targetDir, config.binaryName);

  if (await fs.pathExists(targetBinaryPath)) {
    const stats = await fs.stat(targetBinaryPath);

    console.log(
      chalk.green(
        `PDFium already available for ${target} (${(stats.size / 1024 / 1024).toFixed(2)} MB)`,
      ),
    );

    return;
  }

  console.log(chalk.blue(`Downloading PDFium for ${target}`));

  const archiveName = config.pdfiumArchive;
  const url = `${BASE_URL}/${archiveName}`;

  const tempDir = path.join(__dirname, "../temp/pdfium");
  const archivePath = path.join(tempDir, archiveName);
  const extractPath = path.join(tempDir, target);

  await fs.ensureDir(tempDir);

  console.log(chalk.gray(`  URL: ${url}`));

  await downloadFile(url, archivePath);

  console.log(chalk.gray(`  Extracting archive`));

  await extractArchive(archivePath, extractPath);

  const binaryPath = await findBinary(extractPath, config.binaryName);

  await fs.copy(binaryPath, targetBinaryPath, { overwrite: true });

  const stats = await fs.stat(targetBinaryPath);

  console.log(
    chalk.green(
      `  Saved ${config.binaryName} (${(stats.size / 1024 / 1024).toFixed(2)} MB)`,
    ),
  );
}

async function main() {
  const args = process.argv.slice(2);

  const downloadAll = args.includes("--all");

  let targets: string[];

  if (downloadAll) {
    targets = Object.keys(PLATFORM_MAPPINGS);

    console.log(chalk.cyan("Downloading PDFium for all supported targets"));
  } else {
    const currentTarget = getCurrentTarget();

    targets = [currentTarget];

    console.log(chalk.cyan(`Target platform: ${currentTarget}`));
  }

  let success = 0;
  let failed = 0;

  for (const target of targets) {
    try {
      console.log(chalk.yellow(`\nProcessing ${target}`));

      await downloadPdfiumForTarget(target);

      success++;
    } catch (err) {
      console.error(
        chalk.red(`Failed for ${target}`),
        err instanceof Error ? err.message : err,
      );

      failed++;
    }
  }

  await fs.remove(path.join(__dirname, "../temp"));

  console.log("\n");

  console.log(chalk.cyan("Summary"));
  console.log(chalk.green(`  Successful: ${success}`));

  if (failed > 0) {
    console.log(chalk.red(`  Failed: ${failed}`));
  }

  console.log(chalk.green("\nPDFium setup completed"));
}

main().catch((err) => {
  console.error(chalk.red("Fatal error"), err);
  process.exit(1);
});
