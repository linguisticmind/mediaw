# mediaw (Mediawarrior)

Mediawarrior is a time-tracking plugin for [mpv](https://github.com/mpv-player/mpv/). It talks to [Timewarrior](https://github.com/GothenburgBitFactory/timewarrior) to help you track what you watch or listen to in mpv player. Language learners will appreciate Mediawarrior's ability to automatically add a language tag to a Timewarrior entry and an increased awareness of how much time you spend consuming content in your target language.

Video tutorials:

<table>
    <tr>
        <td align='center'>
            <b>Mediawarrior v0.1.0</b>
        </td>
        <td align='center'>
            Related: <a href='https://github.com/linguisticmind/watchtower'><b>watchtower</b></a><br>(useful Timewarrior-related scripts)
        </td>
    </tr>
    <tr>
        <td>
            <a href='https://www.youtube.com/watch?v=PIY8OpESyt4'>
                <img src='https://img.youtube.com/vi/PIY8OpESyt4/0.jpg' alt='Mindful Technology - Mediawarrior: a time tracker for mpv' width='360'>
            </a>
        </td>
        <td>
            <a href='https://www.youtube.com/watch?v=LVvM3Yq7yGo'>
                <img src='https://img.youtube.com/vi/LVvM3Yq7yGo/0.jpg' alt='Mindful Technology - watchtower: organize your favorite tasks for the watch command' width='360'>
            </a>
        </td>
    </tr>
</table>

<a href='https://ko-fi.com/linguisticmind'><img src='https://github.com/linguisticmind/linguisticmind/raw/master/res/kofi/kofi_donate_1.svg' alt='Support me on Ko-fi' height='48'></a>

## Changelog

<table>
    <tr>
        <td>
            <a href='https://github.com/linguisticmind/mediaw/releases/tag/v0.1.1'>0.1.1</a>
        </td>
        <td>
            2025-11-23
        </td>
        <td>
            <p>
                Fixed an issue with <code>language_props_check</code>: was unable to get past <code>slang</code> or <code>alang</code> in the check sequence, whichever came first.
            </p>
            <p>
                Fixed erroneous OSD messages: when arming tracking while the player is paused, retro time difference would be displayed even if armed in non-retro mode.
            </p>
        </td>
    </tr>
</table>

[Read more](CHANGELOG.md)

## Dependencies

### Required

Required dependencies must be installed in order for Mediawarrior to work.

<table>
    <tr>
        <th>Name</th>
        <th>Installation</th>
        <th>Notes</th>
    </tr>
    <tr>
        <td><b>Timewarrior</b></td>
        <td><code>sudo&nbsp;apt&nbsp;install&nbsp;timewarrior</code></td>
        <td>
            <p>Homepage: <a href='https://timewarrior.net/'>https://timewarrior.net/</a></p>
            <p>GitHub: <a href='https://github.com/GothenburgBitFactory/timewarrior'>https://github.com/GothenburgBitFactory/timewarrior</a></p>
        </td>
    </tr>
</table>

## Installation and upgrading

```bash
# Install:
cd ~/.config/mpv/scripts
git clone https://github.com/linguisticmind/mediaw.git
# Upgrade:
cd ~/.config/mpv/scripts/mediaw
git pull
```

## Options

Options can be set either on the command line, or in a configuration file.

In both cases, this script's identifier&nbsp;&ndash; `mediaw`&nbsp;&ndash; will be needed.

Use `--script-opts=<identifier>-<option>=<value>,...` to set options on the command line.

To set options in a configuration file, create the following file: `~/.config/mpv/script-opts/<identifier>.conf`. Set options in the file, one per line, in the following fashion: `<option>=<value>`.

More information on `mpv`'s `script-opts` command line and configuration file syntax can be found [here](https://mpv.io/manual/master/#configuration) (based on the example of the built-in [`osc.lua`](https://github.com/mpv-player/mpv/blob/master/player/lua/osc.lua) script).

The table below lists the options that are available for this script.

NOTE: The default values are shown as they appear in the script's source code written in Lua. In `mpv`, when passing script options on the command line, or setting them in a configuration file, the words `yes` and `no` are used for Lua's `true` and `false`, and string values are not quoted.

<table>
    <tr>
        <th>Option</th>
        <th>Default value</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>
            <code>tag</code>
        </td>
        <td>
            <code>'mediaw'</code>
        </td>
        <td>
            <p>
                Main Timewarrior tag.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>language_tag</code>
        </td>
        <td>
            <code>true</code>
        </td>
        <td>
            <p>
                Whether to add a language tag.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>language_props_check</code>
        </td>
        <td>
            <code>'current-tracks/sub/lang,slang,current-tracks/audio/lang,alang'</code>
        </td>
        <td>
            <p>
                A comma-separated list of <code>mpv</code> properties to check to determine the language used for the language tag.
            </p>
            <p>
                Properties are checked in the specified order. The first non-<code>nil</code> value is used.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>language</code>
        </td>
        <td>
            <code>''</code>
        </td>
        <td>
            <p>
                Set the language used for the language tag manually.
            </p>
            <p>
                If set to a non-empty string, overrides <code>language_props_check</code>.
            </p>
            <p>
                Must be a valid <a href='https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes#Table'>two- or three-letter ISO 639 language code</a>. The language tag will then be formatted according to the value of <code>language_tag_format</code>.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>language_tag_format</code>
        </td>
        <td>
            <code>'alpha_2'</code>
        </td>
        <td>
            <p>
                Format of the language tag.
            </p>
            <p>
                Possible values:
                <dl>
                    <dt><code>'alpha_2'</code>, <a href='https://en.wikipedia.org/wiki/ISO_639-1'><code>'iso_639_1'</code></a></dt>
                    <dd><a href='https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes#Table'>Two-letter language codes</a>.</dd>
                </dl>
                <dl>
                    <dt><code>'alpha_3'</code>, <a href='https://en.wikipedia.org/wiki/ISO_639-2'><code>'iso_639_2'</code></a></dt>
                    <dd><a href='https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes#Table'>Three-letter language codes</a>. Adding <code>.b</code> or <code>.t</code> to the value swithes between <a href='https://en.wikipedia.org/wiki/ISO_639-2#B_and_T_codes'>bibliographic and terminological codes</a>. The default is bibliographic.</dd>
                </dl>
                <dl>
                    <dt><code>'name'</code></dt>
                    <dd>Language name in English.</dd>
                </dl>
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>osd</code>
        </td>
        <td>
            <code>true</code>
        </td>
        <td>
            <p>
                Whether to show on-screen messages.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>debug</code>
        </td>
        <td>
            <code>false</code>
        </td>
        <td>
            <p>
                Show debug messages in the console.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <code>dry_run</code>
        </td>
        <td>
            <code>false</code>
        </td>
        <td>
            <p>
                Suppress execution of shell commands.
            </p>
        </td>
    </tr>
</table>

## Keybindings

[**Video tutorial**](https://youtu.be/rm1cSU88U2Y&t=12m44s)

Keybindings can be remapped in `~/.config/mpv/input.conf`. Add a line in the following format to remap a keybinding: `<key> script-binding <name>`.

If you remap a keybinding, you will likely want to disable the default keybinding by adding `<default key> ignore` to `~/.config/mpv/input.conf`. See the video tutorial linked to above for a demonstration and for information on how to [see what a given key is currently mapped to](https://youtu.be/rm1cSU88U2Y&t=15m06s) in `mpv`.

The following keybindings are available for this script:

| Key | Name | Description |
| --- | --- | --- |
| `Ctrl+t` | `mediaw-start` | Start tracking. |
| `Ctrl+Alt+t` | `mediaw-start-retro` | Start tracking and retroactively correct the start time to the time when the file was open. |
| `Ctrl+T` | `mediaw-stop` | Stop tracking. |
| `Ctrl+Alt+T` | `mediaw-cancel` | Stop tracking and delete the entry. |
| `Ctrl+SPACE` | `mediaw-pause` | Pause playback and tracking. Tracking will resume when the player is unpaused. |
| `Ctrl+Alt-SPACE` | `mediaw-pause-on-next` | Pause playback and tracking when the next file in the playlist is reached. |

## License

[GNU General Public License v3.0](LICENSE)
