/**
 * Parses HTML from uod.edu.ly/Result_College.php into grade rows.
 * Adjust selectors when the portal markup is confirmed with IT.
 */

export interface PhpGradeRow {
  courseCode: string;
  courseName: string;
  grade: string;
  semester: string;
}

const DEFAULT_SEMESTER = "current";

/**
 * Extract rows from portal HTML (table-based layout).
 * Falls back to empty list when structure is unrecognized.
 */
export function parseResultHtml(html: string, semester = DEFAULT_SEMESTER): PhpGradeRow[] {
  const rows: PhpGradeRow[] = [];

  // Common pattern: <tr> with course code, name, grade cells
  const rowRegex =
    /<tr[^>]*>[\s\S]*?<td[^>]*>\s*([^<]+)\s*<\/td>[\s\S]*?<td[^>]*>\s*([^<]+)\s*<\/td>[\s\S]*?<td[^>]*>\s*([^<]+)\s*<\/td>[\s\S]*?<\/tr>/gi;

  let match: RegExpExecArray | null;
  while ((match = rowRegex.exec(html)) !== null) {
    const courseCode = cleanCell(match[1]);
    const courseName = cleanCell(match[2]);
    const grade = cleanCell(match[3]);

    if (!courseCode || !courseName || isHeaderRow(courseCode, courseName)) {
      continue;
    }

    rows.push({
      courseCode,
      courseName,
      grade,
      semester,
    });
  }

  return rows;
}

function cleanCell(raw: string): string {
  return raw.replace(/&nbsp;/g, " ").replace(/\s+/g, " ").trim();
}

function isHeaderRow(code: string, name: string): boolean {
  const lower = `${code} ${name}`.toLowerCase();
  return (
    lower.includes("رمز") ||
    lower.includes("المادة") ||
    lower.includes("الدرجة") ||
    lower.includes("course")
  );
}
