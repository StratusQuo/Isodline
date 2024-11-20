module app;

import isocline;
import std.stdio;
import std.algorithm;
import std.array;
import std.string;
import std.path;
import std.regex;
import std.file : dirEntries, SpanMode;

// Enhanced custom highlighter function with lighter colors
extern(C) void customHighlighter(ic_highlight_env_t* henv, const(char)* text, void* arg) {
	string t = text.fromStringz.idup;
	
	// Keywords
	auto keywordRegex = regex(r"\b(if|else|while|for|return|function)\b");
	foreach (m; matchAll(t, keywordRegex)) {
		ic_highlight(henv, cast(long)m.pre.length, cast(long)m.hit.length, "fg=#4B8BBE"); // Light blue
	}

	// Strings
	auto stringRegex = regex(`"[^"]*"`);
	foreach (m; matchAll(t, stringRegex)) {
		ic_highlight(henv, cast(long)m.pre.length, cast(long)m.hit.length, "fg=#76AC5F"); // Light green
	}

	// Numbers
	auto numberRegex = regex(r"\b\d+\b");
	foreach (m; matchAll(t, numberRegex)) {
		ic_highlight(henv, cast(long)m.pre.length, cast(long)m.hit.length, "fg=#D19A66"); // Light orange
	}

	// Comments
	auto commentRegex = regex(r"//.*$");
	foreach (m; matchAll(t, commentRegex)) {
		ic_highlight(henv, cast(long)m.pre.length, cast(long)m.hit.length, "fg=#A9A9A9"); // Light gray
	}

	// Parentheses, brackets, and braces
	foreach (i, dchar c; t) {
		if (c == '(' || c == ')' || c == '[' || c == ']' || c == '{' || c == '}') {
			ic_highlight(henv, cast(long)i, 1, "fg=#FF69B4"); // Light pink
		}
	}
}

// Custom completer function with partial matching
extern(C) void customCompleter(ic_completion_env_t* cenv, const(char)* prefix) {
	string p = prefix.fromStringz.idup.toLower();
	string[] commands = ["hello", "help", "quit", "highlight", "unicode", "braces", "indent", "colors", "hint", "files", "search"];
	foreach (cmd; commands.filter!(c => c.toLower().canFind(p))) {
		ic_add_completion(cenv, cmd.toStringz);
	}
}

// Custom filename completer with partial matching
extern(C) void filenameCompleter(ic_completion_env_t* cenv, const(char)* prefix) {
	string p = prefix.fromStringz.idup;
	string dir = p.dirName;
	string filePrefix = p.baseName.toLower();

	try {
		foreach (string name; dirEntries(dir == "" ? "." : dir, SpanMode.shallow)) {
			if (name.baseName.toLower().canFind(filePrefix)) {
				ic_add_completion(cenv, name.toStringz);
			}
		}
	} catch (Exception e) {
		// Handle or ignore directory access errors
	}
}

void main() {
	// Enable various features
	ic_enable_color(true);
	ic_enable_multiline(true);
	ic_enable_highlight(true);
	ic_enable_completion_preview(true);
	ic_enable_auto_tab(true);
	ic_enable_hint(true);
	ic_set_hint_delay(300);
	ic_enable_brace_matching(true);
	ic_enable_brace_insertion(true);
	ic_enable_multiline_indent(true);

	// Set custom prompt markers
	ic_set_prompt_marker("D> ".ptr, "... ".ptr);

	// Set up history
	ic_set_history("isocline_history.txt".ptr, 100);

	// Set custom highlighter
	ic_set_default_highlighter(cast(ic_highlight_fun_t*)&customHighlighter, null);

	// Define some styles
	ic_style_def("title".ptr, "bold fg=#4B8BBE".ptr);  // Light blue
	ic_style_def("info".ptr, "italic fg=#76AC5F".ptr); // Light green
	ic_style_def("unicode".ptr, "fg=#FF69B4".ptr);     // Light pink

	writeln("Welcome to the Enhanced Isocline D binding test!");
	writeln("Type 'help' for available commands or 'quit' to exit.");

	string input;
	while (true) {
		input = readline("");
		if (input is null || input == "quit") break;

		// Process the input
		switch (input) {
			case "help":
				ic_style_open("title".ptr);
				println("Available commands:");
				ic_style_close();
				println("  help       - Show this help");
				println("  quit       - Exit the program");
				println("  unicode    - Test Unicode input and output");
				println("  braces     - Test brace matching and jumping");
				println("  indent     - Test auto indentation");
				println("  colors     - Test 24-bit color output");
				println("  hint       - Test inline hinting");
				println("  files      - Test filename completion");
				println("  search     - Test incremental history search");
				break;

			case "unicode":
				ic_style_open("unicode".ptr);
				println("Unicode test: こんにちは世界 • λ • π • ∑ • 🌍 🌎 🌏");
				ic_style_close();
				println("Try inputting some Unicode characters:");
				auto unicodeInput = readline("Unicode> ");
				if (unicodeInput !is null) {
					println("You entered: " ~ unicodeInput);
				}
				break;

			case "braces":
				println("Type an expression with braces, brackets, or parentheses.");
				println("Use ctrl+] to jump to matching brace.");
				ic_set_default_completer(null, null);  // Disable default completion for this test
				auto braceInput = readline("Braces> ");
				if (braceInput !is null) {
					println("You entered: " ~ braceInput);
				}
				break;

			case "indent":
				println("Type a multi-line input with braces to test auto-indentation.");
				println("Press Enter twice to finish input.");
				ic_set_default_completer(null, null);  // Disable default completion for this test
				auto indentInput = readline("Indent> ");
				if (indentInput !is null) {
					println("You entered:\n" ~ indentInput);
				}
				break;

			case "colors":
				ic_printf("24-bit color test:\n".ptr);
				for (int r = 0; r < 256; r += 51) {
					for (int g = 0; g < 256; g += 51) {
						for (int b = 0; b < 256; b += 51) {
							uint color = (r << 16) | (g << 8) | b;
							ic_term_color_rgb(true, color);
							ic_printf("■".ptr);
						}
					}
					ic_printf("\n".ptr);
				}
				ic_term_reset();
				break;

			case "hint":
				println("Type 'hello' to see inline hinting in action.");
				ic_set_default_completer(cast(ic_completer_fun_t*)&customCompleter, null);
				auto hintInput = readline("Hint> ");
				if (hintInput !is null) {
					println("You entered: " ~ hintInput);
				}
				break;

			case "files":
				println("Test filename completion. Type part of a filename and press Tab.");
				ic_set_default_completer(cast(ic_completer_fun_t*)&filenameCompleter, null);
				auto fileInput = readline("File> ");
				if (fileInput !is null) {
					println("You entered: " ~ fileInput);
				}
				break;
			case "highlight":
				println("Enter some code to test syntax highlighting.");
				println("Try using keywords (if, else, while, for, return, function),");
				println("strings, numbers, comments (//), and parentheses/brackets/braces.");
				println("Press Enter twice to finish input.");
				
				string codeInput;
				string line;
				while ((line = readline("Code> ")) != "") {
					codeInput ~= line ~ "\n";
				}
				
				if (codeInput != "") {
					println("You entered:");
					ic_println(codeInput.toStringz);
					println("(The above should be syntax highlighted)");
				}
				break;
			case "search":
				println("Test incremental history search.");
				println("Press Ctrl+R to start reverse search, type to filter, Ctrl+R again to cycle through results.");
				auto searchInput = readline("Search> ");
				if (searchInput !is null) {
					println("You entered: " ~ searchInput);
				}
				break;

			default:
				ic_printf("You entered: %s\n".ptr, input.toStringz);
				break;
		}

		// Add to history
		historyAdd(input);
	}

	println("Thank you for testing the Enhanced Isocline D bindings!");
}