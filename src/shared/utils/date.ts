export function parsePdfDate(pdfDate?: string | null): Date | null {
  if (!pdfDate) return null;

  let value = pdfDate.startsWith("D:") ? pdfDate.slice(2) : pdfDate;

  let timezone = "Z";

  const tzMatch = value.match(/([+-Z])(\d{2})?'?(\d{2})?'?$/);

  if (tzMatch) {
    if (tzMatch[1] === "Z") {
      timezone = "Z";
      value = value.replace(/Z$/, "");
    } else if (tzMatch[1] === "+" || tzMatch[1] === "-") {
      const sign = tzMatch[1];
      const hours = tzMatch[2] ?? "00";
      const minutes = tzMatch[3] ?? "00";
      timezone = `${sign}${hours}:${minutes}`;
      value = value.replace(/([+-])(\d{2})?'?(\d{2})?'?$/, "");
    }
  }

  const year = value.substring(0, 4);
  const month = value.substring(4, 6) || "01";
  const day = value.substring(6, 8) || "01";
  const hour = value.substring(8, 10) || "00";
  const minute = value.substring(10, 12) || "00";
  const second = value.substring(12, 14) || "00";

  if (!year) return null;

  const isoString = `${year}-${month}-${day}T${hour}:${minute}:${second}${timezone}`;
  const date = new Date(isoString);

  return isNaN(date.getTime()) ? null : date;
}

export function formatPdfDateTime(pdfDate?: string | null, locale = undefined) {
  const date = parsePdfDate(pdfDate);
  if (!date) return "";

  return date.toLocaleString(locale, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
}