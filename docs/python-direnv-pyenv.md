# Python Environment

This procedure creates a project-local Python environment with pyenv, direnv, and pip.

## Requirements

- The shell loads the direnv hook from `base/.bashrc`.
- `pyenv` is available on `$PATH`.
- The project has a writable directory.

## Where packages go

`layout python` stores the virtual environment under the project `.direnv` directory. `pip` installs packages there, not globally.

## Build the environment

- Move into the project directory:

  ```bash
  cd ~/src/example-project
  ```

- Install the Python version with pyenv:

  ```bash
  pyenv install -s 3.14.5
  ```

- Write the local Python version:

  ```bash
  pyenv local 3.14.5
  ```

- Write the `.envrc` file:

  ```bash
  cat > .envrc <<'EOF'
  layout pyenv 3.14.5
  layout python
  EOF
  ```

`layout pyenv 3.14.5` selects the Python interpreter that pyenv installed.
`layout python` creates and loads the virtual environment for that interpreter.
Keep this order because the virtual environment must use the selected Python version.

The direnv stdlib documents both functions: [direnv-stdlib](https://direnv.net/man/direnv-stdlib.1.html).

- If the project needs shared variables, source an env-source file in `.envrc`:

  ```bash
  cat >> .envrc <<'EOF'
  source ~/.config/env-source/<name>
  EOF
  ```

  [Load project environments](env-source.md) explains this reuse pattern.

- Allow direnv to load the file:

  ```bash
  direnv allow
  ```

- Install packages into the project environment:

  ```bash
  pip install requests pytest
  ```

The project now has `.python-version`, `.envrc`, and a virtual environment under `.direnv`.

## Maintain packages

- Update pip:

  ```bash
  pip install --upgrade pip
  ```

- Update one package:

  ```bash
  pip install --upgrade requests
  ```

- Delete one package:

  ```bash
  pip uninstall requests
  ```

- Install packages from `requirements.txt`:

  ```bash
  pip install -r requirements.txt
  ```

- Freeze installed versions to `requirements.txt`:

  ```bash
  pip freeze > requirements.txt
  ```

## Reset the environment

- Delete the direnv environment directory:

  ```bash
  rm -rf .direnv
  ```

- Reload direnv:

  ```bash
  direnv reload
  ```

Direnv recreates `.direnv` from `.envrc`, and `pip` starts with an empty package set.
