module isocline;

import core.stdc.stdarg;
import core.stdc.stddef;
import core.stdc.stdint;
import core.stdc.string: strncpy, strcpy;
import std.ascii: toLower;
import std.algorithm: canFind;
import std.traits : isSomeString;
import std.string;
import std.ascii;
import std.uni;
import std.functional : compose, pipe, memoize;

extern(C):

// Constants
enum IC_VERSION = 104;

// Basic types
alias ic_color_t = uint;

// Function pointer types
alias ic_completer_fun_t = void function(ic_completion_env_t* cenv, const(char)* prefix);
alias ic_highlight_fun_t = void function(ic_highlight_env_t* henv, const(char)* input, void* arg);
alias ic_is_char_class_fun_t = bool function(const(char)* s, long len);
alias ic_highlight_format_fun_t = char* function(const(char)* s, void* arg);
alias ic_malloc_fun_t = void* function(size_t size);
alias ic_realloc_fun_t = void* function(void* p, size_t newsize);
alias ic_free_fun_t = void function(void* p);

// Structs
struct ic_completion_env_t;
struct ic_highlight_env_t;
struct ic_style_t;

// Function declarations

// D wrapper functions
string readline(string promptText) {
    import core.memory: GC;
    
    // Disable GC for readline (potentially risky)
    scope(exit) GC.enable();
    GC.disable();

    auto result = ic_readline(promptText.toStringz);
    if (result is null) return null;
    scope(exit) ic_free(result);
    return result.fromStringz.idup;
}

void print(string s) {
    ic_print(s.toStringz);
}

void println(string s) {
    ic_println(s.toStringz);
}

void printf(string fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ic_vprintf(fmt.toStringz, args);
    va_end(args);
}

bool enableMultiline(bool enable) {
    return ic_enable_multiline(enable);
}

bool enableColor(bool enable) {
    return ic_enable_color(enable);
}

void setHistory(string fname, long maxEntries) {
    ic_set_history(fname.toStringz, maxEntries);
}

void historyAdd(string entry) {
    ic_history_add(entry.toStringz);
}

void historyClear() {
    ic_history_clear();
}

// Readline
char* ic_readline(const(char)* prompt_text);
char* ic_readline_ex(const(char)* prompt_text,
                    ic_completer_fun_t* completer, void* completer_arg,
                    ic_highlight_fun_t* highlighter, void* highlighter_arg);

// Formatted Text
void ic_print(const(char)* s);
void ic_println(const(char)* s);
void ic_printf(const(char)* fmt, ...);
void ic_vprintf(const(char)* fmt, va_list args);
void ic_style_def(const(char)* style_name, const(char)* fmt);
void ic_style_open(const(char)* fmt);
void ic_style_close();

// History
void ic_set_history(const(char)* fname, long max_entries);
void ic_history_remove_last();
void ic_history_clear();
void ic_history_add(const(char)* entry);

// Completion
void ic_set_default_completer(ic_completer_fun_t* completer, void* arg);
bool ic_add_completion(ic_completion_env_t* cenv, const(char)* completion);
bool ic_add_completion_ex(ic_completion_env_t* cenv, const(char)* completion, const(char)* display, const(char)* help);
bool ic_add_completions(ic_completion_env_t* cenv, const(char)* prefix, const(char*)* completions);
void ic_complete_filename(ic_completion_env_t* cenv, const(char)* prefix, char dir_separator, const(char)* roots, const(char)* extensions);
void ic_complete_word(ic_completion_env_t* cenv, const(char)* prefix, ic_completer_fun_t* fun, ic_is_char_class_fun_t* is_word_char);
void ic_complete_qword(ic_completion_env_t* cenv, const(char)* prefix, ic_completer_fun_t* fun, ic_is_char_class_fun_t* is_word_char);
void ic_complete_qword_ex(ic_completion_env_t* cenv, const(char)* prefix, ic_completer_fun_t fun, 
                        ic_is_char_class_fun_t* is_word_char, char escape_char, const(char)* quote_chars);

// Syntax Highlighting
void ic_set_default_highlighter(ic_highlight_fun_t* highlighter, void* arg);
void ic_highlight(ic_highlight_env_t* henv, long pos, long count, const(char)* style);
void ic_highlight_formatted(ic_highlight_env_t* henv, const(char)* input, const(char)* formatted);

// Options
void ic_set_prompt_marker(const(char)* prompt_marker, const(char)* continuation_prompt_marker);
const(char)* ic_get_prompt_marker();
const(char)* ic_get_continuation_prompt_marker();
bool ic_enable_multiline(bool enable);
bool ic_enable_beep(bool enable);
bool ic_enable_color(bool enable);
bool ic_enable_history_duplicates(bool enable);
bool ic_enable_auto_tab(bool enable);
bool ic_enable_completion_preview(bool enable);
bool ic_enable_multiline_indent(bool enable);
bool ic_enable_inline_help(bool enable);
bool ic_enable_hint(bool enable);
long ic_set_hint_delay(long delay_ms);
bool ic_enable_highlight(bool enable);
void ic_set_tty_esc_delay(long initial_delay_ms, long followup_delay_ms);
bool ic_enable_brace_matching(bool enable);
void ic_set_matching_braces(const(char)* brace_pairs);
bool ic_enable_brace_insertion(bool enable);
void ic_set_insertion_braces(const(char)* brace_pairs);

// Advanced Completion
const(char)* ic_completion_input(ic_completion_env_t* cenv, long* cursor);
void* ic_completion_arg(const(ic_completion_env_t)* cenv);
bool ic_has_completions(const(ic_completion_env_t)* cenv);
bool ic_stop_completing(const(ic_completion_env_t)* cenv);
bool ic_add_completion_prim(ic_completion_env_t* cenv, const(char)* completion, 
                            const(char)* display, const(char)* help, 
                            long delete_before, long delete_after);

// Helper Functions
long ic_prev_char(const(char)* s, long pos);
long ic_next_char(const(char)* s, long pos);
bool ic_starts_with(const(char)* s, const(char)* prefix);
bool ic_istarts_with(const(char)* s, const(char)* prefix);
bool ic_char_is_white(const(char)* s, long len);
bool ic_char_is_nonwhite(const(char)* s, long len);
bool ic_char_is_separator(const(char)* s, long len);
bool ic_char_is_nonseparator(const(char)* s, long len);
bool ic_char_is_letter(const(char)* s, long len);
bool ic_char_is_digit(const(char)* s, long len);
bool ic_char_is_hexdigit(const(char)* s, long len);
bool ic_char_is_idletter(const(char)* s, long len);
bool ic_char_is_filename_letter(const(char)* s, long len);
long ic_is_token(const(char)* s, long pos, ic_is_char_class_fun_t* is_token_char);
long ic_match_token(const(char)* s, long pos, ic_is_char_class_fun_t* is_token_char, const(char)* token);
long ic_match_any_token(const(char)* s, long pos, ic_is_char_class_fun_t* is_token_char, const(char*)* tokens);

// Terminal Functions
void ic_term_init();
void ic_term_done();
void ic_term_flush();
void ic_term_write(const(char)* s);
void ic_term_writeln(const(char)* s);
void ic_term_writef(const(char)* fmt, ...);
void ic_term_vwritef(const(char)* fmt, va_list args);
void ic_term_style(const(char)* style);
void ic_term_bold(bool enable);
void ic_term_underline(bool enable);
void ic_term_italic(bool enable);
void ic_term_reverse(bool enable);
void ic_term_color_ansi(bool foreground, int color);
void ic_term_color_rgb(bool foreground, uint32_t color);
void ic_term_reset();
int ic_term_get_color_bits();

// Async Support
bool ic_async_stop();

// Custom Allocation
void ic_init_custom_alloc(ic_malloc_fun_t* _malloc, ic_realloc_fun_t* _realloc, ic_free_fun_t* _free);
void ic_free(void* p);
void* ic_malloc(size_t sz);
const(char)* ic_strdup(const(char)* s);
