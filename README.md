# Isodline: D Bindings for the Isocline Library


This project provides D bindings for the [Isocline](https://github.com/daanx/isocline) library, a powerful and portable alternative to GNU Readline. 

Isocline offers rich editing capabilities, including multi-line input, syntax highlighting, auto-completion, history management, and Unicode support.  These D bindings make it easy to integrate Isocline's features into your D applications.

## Features

* **Multi-line Editing:**  Easily handle multi-line input with automatic indentation and continuation prompts.
* **Syntax Highlighting:** Customizable syntax highlighting using regular expressions or other methods, making code input more readable.
* **Auto-Completion:**  Provide suggestions and complete partially typed words, filenames, or other custom completions.
* **History Management:** Maintain and navigate through command history, including persistent history stored on disk.
* **Unicode Support:** Full Unicode support for input and output, enabling internationalization.
* **Customizable Prompts and Styles:**  Set prompt markers and use bbcode style tags for colorful and informative prompts.
* **Cross-Platform Compatibility:** Works seamlessly on Linux, macOS, and Windows.


## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/YourGitHubUsername/isocline-d.git
   ```

2. Build the Isocline library (see [Isocline's build instructions](https://github.com/daanx/isocline#build-the-library)).  For example, to build as a static library:

    ```bash
    cd isocline-d/isocline
    mkdir build
    cd build
    cmake ..
    cmake --build .
    ```
3.  Update the `dub.json` to point to the appropriate `libisocline.a` (or `.lib`) that you created.

4. Build the D bindings:

    ```bash
    cd isocline-d
    dub build
    ```

## Usage


```d
import isocline;
import std.stdio;

void main() {
    // Enable color output and multi-line input
    enableColor(true);
    enableMultiline(true);

    // Set the prompt
    ic_set_prompt_marker("> ", "... ");

    // Read a line of input
    string input = readline("Enter text: ");

    if (input !is null) {
        writeln("You entered: ", input);
    }
}
```
# Run the Example

You can compile and run the [example] as:
```
$ gcc -o example -Iinclude test/example.c src/isocline.c
$ ./example
```

or, the Haskell [example][HaskellExample]:
```
$ ghc -ihaskell test/Example.hs src/isocline.c
$ ./test/Example
```


# Editing with Isodline

Isocline tries to be as compatible as possible with standard [GNU Readline] key bindings.

### Overview:

```apl
       home/ctrl-a       cursor     end/ctrl-e
         ┌─────────────────┼───────────────┐    (navigate)
         │     ctrl-left   │  ctrl-right   │
         │         ┌───────┼──────┐        │    ctrl-r   : search history
         ▼         ▼       ▼      ▼        ▼    tab      : complete word
  prompt> it is the quintessential language     shift-tab: insert new line
         ▲         ▲              ▲        ▲    esc      : delete input, done
         │         └──────────────┘        │    ctrl-z   : undo
         │    alt-backsp        alt-d      │
         └─────────────────────────────────┘    (delete)
       ctrl-u                          ctrl-k
```

<sub>Note: on macOS, the meta (alt) key is not directly available in most terminals. 
Terminal/iTerm2 users can activate the meta key through
`Terminal` &rarr; `Preferences` &rarr; `Settings` &rarr; `Use option as meta key`.</sub>

### Key Bindings

These are also shown when pressing `F1` on a Isocline prompt. We use `^` as a shorthand for `ctrl-`:

| Navigation        |                                                 |
|-------------------|-------------------------------------------------|
| `left`,`^b`       | go one character to the left |
| `right`,`^f   `   | go one character to the right |
| `up           `   | go one row up, or back in the history |
| `down         `   | go one row down, or forward in the history |
| `^left        `   | go to the start of the previous word |
| `^right       `   | go to the end the current word |
| `home`,`^a    `   | go to the start of the current line |
| `end`,`^e     `   | go to the end of the current line |
| `pgup`,`^home `   | go to the start of the current input |
| `pgdn`,`^end  `   | go to the end of the current input |
| `alt-m        `   | jump to matching brace |
| `^p           `   | go back in the history |
| `^n           `   | go forward in the history |
| `^r`,`^s      `   | search the history starting with the current word |
  

| Deletion        |                                                 |
|-------------------|-------------------------------------------------|
| `del`,`^d     `   | delete the current character |
| `backsp`,`^h  `   | delete the previous character |
| `^w           `   | delete to preceding white space |
| `alt-backsp   `   | delete to the start of the current word |
| `alt-d        `   | delete to the end of the current word |
| `^u           `   | delete to the start of the current line |
| `^k           `   | delete to the end of the current line |
| `esc          `   | delete the current input, or done with empty input |
  

| Editing           |                                                 |
|-------------------|-------------------------------------------------|
| `enter        `   | accept current input |
| `^enter`,`^j`,`shift-tab` | create a new line for multi-line input |
| `^l           `   | clear screen |
| `^t           `   | swap with previous character (move character backward) |
| `^z`,`^_      `   | undo |
| `^y           `   | redo |
| `tab          `   | try to complete the current input |
  

| Completion menu   |                                                 |
|-------------------|-------------------------------------------------|
| `enter`,`left`    | use the currently selected completion |
| `1` - `9`         | use completion N from the menu |
| `tab, down    `   | select the next completion |
| `shift-tab, up`   | select the previous completion |
| `esc          `   | exit menu without completing |
| `pgdn`,`^enter`,`^j`   | show all further possible completions |
  

| Incremental history search        |                                                 |
|-------------------|-------------------------------------------------|
| `enter        `   | use the currently found history entry |
| `backsp`,`^z  `   | go back to the previous match (undo) |
| `tab`,`^r`,`up`   | find the next match |
| `shift-tab`,`^s`,`down`  | find an earlier match |
| `esc          `   | exit search |

See the [`app.d`](./source/app.d) file for a more comprehensive example that demonstrates syntax highlighting, custom completion, and other advanced features.


## Documentation

* **D Bindings:**  Refer to the [DDoc documentation](YOUR_DDOC_LINK_HERE) for a detailed description of the D API.
* **Isocline C Library:** Consult the [Isocline documentation](https://daanx.github.io/isocline/) for in-depth information about the underlying C library, including BBCode styling, keyboard shortcuts, and customization options.


## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.  When submitting code, please adhere to the existing code style and ensure your changes are well-documented.


## License

This project is licensed under the MIT License - see the [LICENSE](./isocline/LICENSE) file for details. The Isocline library is also licensed under the MIT License.
