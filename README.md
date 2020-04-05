[hugo]: https://github.com/HugoCarvalho99
[hugo-pic]: https://github.com/HugoCarvalho99.png?size=120
[nelson]: https://github.com/nelsonmestevao
[nelson-pic]: https://github.com/nelsonmestevao.png?size=120
[pedro]: https://github.com/pedroribeiro22
[pedro-pic]: https://github.com/pedroribeiro22.png?size=120

# Template multi-file

In most software projects, these involve multiple files and directories. The
goal of this project is to create a program capable of generating the initial
setup of the project from a name and a template file.

## :rocket: Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes.

### :inbox_tray: Prerequisites

The following software is required to be installed on your system:

- [make](https://www.gnu.org/software/make/)
- [gcc](https://gcc.gnu.org/releases.html)
- [flex](https://github.com/westes/flex)

### :package: Installation

You can install the program in your computer for your own use.

```
make build
make install
```

### :video_game: Usage

After you have installed the program you can run it from everywhere. Just run
`mkfromtemplate` or `mkft`.

```
mkfromtemplate -o folder_name -t c.tmpl my-awesome-project-in-c
```

The above example will create the file tree under `folder_name/`. The project
name will be `my-awesome-project-in-c`. It will try to use the file `c.tmpl`
if it exists in the current directory, otherwise will search for the file
inside `templates.path` variable defined in the configuration file. The default
configuration is located at `~/.config/mkfromtemplate/config.ini`.

Use `--help` for more help on usage.

### :hammer: Development

Compile the program. If it's the first time you need to run the command twice.

```
make build
```

Run the tests.

```
make test
```

Run the benchmarks.

```
make benchmark
```

Format your code.

```
make fmt
```

Generate the documentation.

```
make doc
```

## :busts_in_silhouette: Team

| [![Hugo][hugo-pic]][hugo] | [![Nelson][nelson-pic]][nelson] | [![Pedro][pedro-pic]][pedro] |
| :-----------------------: | :-----------------------------: | :--------------------------: |
|   [Hugo Carvalho][hugo]   |    [Nelson Estevão][nelson]     |    [Pedro Ribeiro][pedro]    |
