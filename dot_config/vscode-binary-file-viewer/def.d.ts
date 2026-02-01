/**
 * Binary File Viewer Parser API - TypeScript Declarations
 *
 * Complete type definitions for the binary-file-viewer VSCode extension
 * parser scripting environment.
 *
 * @see https://github.com/maziac/binary-file-viewer
 */

/**
 * String object with additional hover value property for display
 */
interface StringWithHover extends String {
  /** Hover text to display in the UI */
  hoverValue?: string | number;
}

/**
 * File data accessor for reading binary file contents
 */
interface FileData {
  /**
   * Read bytes from the file at a specific offset
   * @param offset - File offset to read from
   * @param length - Number of bytes to read (default: 1)
   * @returns Array of byte values (0-255)
   */
  getBytesAt(offset: number, length?: number): number[];

  /**
   * Get the total file size in bytes
   * @returns File size
   */
  getFileSize(): number;
}

/**
 * Single data series for charting
 */
interface Series {
  /** Array of numeric samples */
  samples: number[];
  /** Optional label for the series */
  label?: string;
  /** Optional color for the series (e.g., 'red', '#FF0000') */
  color?: string;
}

/**
 * Chart configuration object
 */
interface ChartConfig {
  /** Chart type: 'line' (default) or 'bar' */
  type?: "line" | "bar";
  /** Array of data series or raw number arrays */
  series: (Series | number[])[];
}

/**
 * Custom color configuration for parser output
 */
interface ColorConfig {
  collapse?: string;
  offset?: string;
  size?: string;
  name?: string;
  value?: string;
  description?: string;
  "row-header"?: string;
  "row-odd"?: string;
  "row-even"?: string;
}

/**
 * Defaults configuration object
 */
interface DefaultsConfig {
  colors?: ColorConfig;
  "dark-colors"?: ColorConfig;
  [key: string]: any;
}

// ============================================================================
// Registration Functions
// ============================================================================

/**
 * Register a file type detector function
 *
 * @param func - Callback function that determines if this parser handles the file.
 *               Should return true if the file should be parsed.
 * @example
 * registerFileType((fileExt, filePath, fileData) => {
 *   if (fileExt === "wav") {
 *     const header = String.fromCharCode(...fileData.getBytesAt(0, 4));
 *     return header === "RIFF";
 *   }
 *   return false;
 * });
 */
declare function registerFileType(
  func: (fileExt: string, filePath: string, fileData: FileData) => boolean,
): void;

/**
 * Register the main parser function
 *
 * @param func - Parser function that reads and displays the file structure
 * @example
 * registerParser(() => {
 *   read(4);
 *   addRow("Header", getStringValue());
 * });
 */
declare function registerParser(func: (filePath?: string) => void): void;

// ============================================================================
// File Reading Functions
// ============================================================================

/**
 * Read bytes from the current file offset
 *
 * Advances the file offset and sets the size for the next value extraction.
 *
 * @param size - Number of bytes to read. Omit to read all remaining bytes.
 *               Use negative values to move offset backwards.
 * @example
 * read(4);
 * const value = getNumberValue();
 */
declare function read(size?: number): void;

/**
 * Read bits from the current file position
 *
 * After reading bits, the next read() call starts on the next byte boundary.
 *
 * @param bitSize - Number of bits to read
 * @example
 * readBits(3);
 * const bits = getBitsValue();
 */
declare function readBits(bitSize: number): void;

/**
 * Read bytes until a specific value is found
 *
 * Useful for reading C-strings and other null-terminated data.
 *
 * @param value - Byte value to search for (default: 0 for null terminator)
 * @example
 * readUntil(0);
 * const str = getStringValue();
 */
declare function readUntil(value?: number): void;

/**
 * Set the absolute file offset
 *
 * @param offset - Absolute offset in file
 * @example
 * setOffset(0x1000);
 */
declare function setOffset(offset: number): void;

/**
 * Get the current file offset
 *
 * @returns Current offset (lastOffset)
 */
declare function getOffset(): number;

/**
 * Set the byte order for multi-byte values
 *
 * @param endianness - 'little' (default) or 'big'
 * @example
 * setEndianness('big');
 */
declare function setEndianness(endianness: "little" | "big"): void;

/**
 * Check if the end of file has been reached
 *
 * @returns true if at end of file
 */
declare function endOfFile(): boolean;

/**
 * Get the number of bytes remaining from current offset
 *
 * @returns Remaining byte count
 */
declare function getRemainingSize(): number;

// ============================================================================
// Value Extraction Functions
// ============================================================================

/**
 * Extract the last read bytes as an unsigned number
 *
 * Safe for values up to 2^53-1. Use getDecimalValue() for larger values.
 *
 * @returns Unsigned number value
 * @example
 * read(4);
 * const age = getNumberValue();
 */
declare function getNumberValue(): number;

/**
 * Extract the last read bytes as a signed number
 *
 * Safe for values between -(2^53-1) and 2^53-1. Use getSignedDecimalValue() for larger values.
 *
 * @returns Signed number value
 */
declare function getSignedNumberValue(): number;

/**
 * Extract the last read bytes as an IEEE754 floating point number
 *
 * Supports 32-bit (4 bytes) and 64-bit (8 bytes) floats.
 *
 * @returns Float value
 * @example
 * read(4);
 * const speed = getFloatNumberValue();
 */
declare function getFloatNumberValue(): number;

/**
 * Extract the last read bytes as a hexadecimal string
 *
 * Returns a String object (not primitive string) with hoverValue property.
 *
 * @returns Hex string without "0x" prefix (e.g., "DEADBEEF")
 * @example
 * read(4);
 * const hex = getHexValue();
 */
declare function getHexValue(): StringWithHover;

/**
 * Extract the last read bytes as a hexadecimal string with "0x" prefix
 *
 * Returns a String object with hoverValue property containing decimal equivalent.
 *
 * @returns Hex string with "0x" prefix (e.g., "0xDEADBEEF")
 */
declare function getHex0xValue(): StringWithHover;

/**
 * Extract the last read bytes as a decimal string
 *
 * Uses BigInt internally for arbitrary precision with large numbers.
 * Returns a String object with hoverValue property.
 *
 * @returns Decimal string
 * @example
 * read(8);
 * const decimal = getDecimalValue();
 */
declare function getDecimalValue(): StringWithHover;

/**
 * Extract the last read bytes as a signed decimal string
 *
 * Uses BigInt internally for arbitrary precision.
 * Returns a String object with hoverValue property.
 *
 * @returns Signed decimal string
 */
declare function getSignedDecimalValue(): StringWithHover;

/**
 * Extract the last read bytes as a string
 *
 * Interprets bytes as ASCII/UTF-8 characters.
 *
 * @returns String value
 * @example
 * read(4);
 * const fourCC = getStringValue();
 */
declare function getStringValue(): string;

/**
 * Extract the last read bytes as a binary bit string
 *
 * Returns a String object with hoverValue property containing hex equivalent.
 *
 * @returns Bit string (e.g., "11010101")
 */
declare function getBitsValue(): StringWithHover;

/**
 * Read chunks of data for visualization (charts, etc.)
 *
 * Interprets the buffer as multiple samples of a given size.
 * Useful for extracting audio samples or similar repeating data.
 *
 * @param sampleSize - Bytes per sample (default: 1)
 * @param offset - Starting offset within the buffer in bytes (default: 0)
 * @param format - 'u' for unsigned (default), 'i' for signed
 * @param skip - Bytes to skip after each sample (default: 0)
 * @returns Array of numeric values
 * @example
 * read(1000);
 * const samples = getData(2, 0, 'i', 2);
 */
declare function getData(
  sampleSize?: number,
  offset?: number,
  format?: "u" | "i",
  skip?: number,
): number[];

// ============================================================================
// Display Functions
// ============================================================================

/**
 * Add a row to the display table
 *
 * Displays a named value with optional description and hover text.
 *
 * @param name - Row name/label
 * @param value - Optional value to display (string, number, or String object)
 * @param description - Optional description text
 * @param valueHover - Optional hover text (e.g., decimal for hex values)
 * @param hexOffset - Display the offset in hexadecimal (default: false)
 * @example
 * addRow("Magic", getHexValue(), "File magic number");
 * addRow("Size", getNumberValue(), "File size in bytes");
 */
declare function addRow(
  name: string,
  value?: string | number | StringWithHover,
  description?: string,
  valueHover?: string | number,
  hexOffset?: boolean,
): void;

/**
 * Set the value of the current/last row
 *
 * Used to update the display value after the row was created with addRow().
 *
 * @param value - New value to display
 * @param valueHover - Optional new hover text
 */
declare function setRowValue(
  value: string | number | StringWithHover,
  valueHover?: string | number,
): void;

/**
 * Make the current row expandable with details
 *
 * Creates a collapsible section for additional information.
 *
 * @param func - Callback function that adds detail rows
 * @param opened - true = initially expanded, false = collapsed (default: false)
 * @example
 * addRow("Header", "...");
 * addDetails(() => {
 *   read(4);
 *   addRow("Sub-field 1", getNumberValue());
 * });
 */
declare function addDetails(func: () => void, opened?: boolean): void;

/**
 * Add a row with automatically calculated details section
 *
 * Combines addRow() and addDetails() in a single call.
 * The provided function should return value, description, and hover text.
 *
 * @param name - Row name
 * @param func - Function returning {value, description, valueHover}
 * @param opened - Initially expanded (default: false)
 * @param hexOffset - Display offset in hex (default: false)
 */
declare function readRowWithDetails(
  name: string,
  func: () => {
    value: string | number | StringWithHover;
    description: string;
    valueHover?: string | number;
  },
  opened?: boolean,
  hexOffset?: boolean,
): void;

/**
 * Display a memory dump (like hexdump)
 *
 * Shows hexadecimal values and ASCII representation.
 *
 * @param enableAscii - Show ASCII column (default: true)
 * @example
 * read(256);
 * addMemDump();
 */
declare function addMemDump(enableAscii?: boolean): void;

/**
 * Add a chart to visualize data
 *
 * Supports line and bar charts with one or more series.
 *
 * @param config - ChartConfig object with type and series
 * @param name - Optional chart name/title
 * @example
 * const samples = getData(2);
 * addChart({ type: 'line', series: [samples] }, "Waveform");
 */
declare function addChart(config: ChartConfig, name?: string): void;

/**
 * Create a data series object for use in addChart()
 *
 * @param samples - Array of numeric values
 * @param color - Optional color (e.g., 'red', '#FF0000')
 * @param label - Optional series label
 * @returns Series object
 */
declare function createSeries(
  samples: number[],
  color?: string,
  label?: string,
): Series;

/**
 * Add a custom HTML5 canvas for drawing
 *
 * Returns a 2D rendering context for custom visualization.
 *
 * @param width - Canvas width in pixels
 * @param height - Canvas height in pixels
 * @param name - Optional canvas name/title
 * @returns 2D canvas context for drawing
 * @example
 * const ctx = addCanvas(400, 300, "Spectrogram");
 * ctx.fillStyle = 'blue';
 * ctx.fillRect(10, 10, 50, 50);
 */
declare function addCanvas(
  width: number,
  height: number,
  name?: string,
): CanvasRenderingContext2D;

/**
 * Display multiline text in a box
 *
 * @param text - Text content (lines separated by '\n')
 * @param width - Box width (optional)
 * @param height - Box height (optional)
 */
declare function addTextBox(
  text: string,
  width?: number,
  height?: number,
): void;

/**
 * Add a standard file header section
 *
 * Displays file size and parser selection info.
 */
declare function addStandardHeader(): void;

/**
 * Set custom colors for the parser output
 *
 * @param config - Color configuration object
 * @example
 * setDefaults({
 *   colors: {
 *     name: '#0000FF',
 *     value: '#00FF00'
 *   }
 * });
 */
declare function setDefaults(config: DefaultsConfig): void;

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * Convert a number to a hexadecimal string
 *
 * @param value - Number to convert
 * @param size - Number of hex digits (e.g., 2 for "0F", 4 for "12FA")
 * @returns Hex string with zero-padding
 * @example
 * const hex = convertToHexString(255, 2); // "FF"
 */
declare function convertToHexString(value: number, size: number): string;

// ============================================================================
// Debug Functions
// ============================================================================

/**
 * Stop parser execution for debugging
 *
 * Throws an exception that halts parsing, useful for debugging.
 */
declare function dbgStop(): void;

/**
 * Log a message to the Binary File Viewer output pane
 *
 * @param args - Values to log (similar to console.log)
 * @example
 * dbgLog("Sample count:", samples.length);
 */
declare function dbgLog(...args: any[]): void;

/**
 * Override the open/closed state of all details sections
 *
 * Useful for debugging and testing parser output.
 *
 * @param open - true (all open), false (all closed), undefined (default behavior)
 */
declare function dbgOverrideDetailsOpen(open: boolean | undefined): void;

// ============================================================================
// Global Built-in Objects Available in Parser
// ============================================================================

/** Math object for mathematical functions */
declare const Math: Math;

/** Number constructor */
declare const Number: NumberConstructor;

/** DataView for reading typed binary data */
declare const DataView: DataViewConstructor;

/** JSON object for parsing and stringifying */
declare const JSON: JSON;

/**
 * Decode a base64 string
 * @param str - Base64 encoded string
 * @returns Decoded string
 */
declare function atob(str: string): string;

/**
 * Encode a string as base64
 * @param str - String to encode
 * @returns Base64 encoded string
 */
declare function btoa(str: string): string;
