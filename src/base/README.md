
# Base

A devcontainer feature

## Example Usage

```json
"features": {
    "ghcr.io/ridhwaans/devcontainer-features/base:1": {
        "version": "latest"
    }
}
```

## Options

| Options Id               | Description                                       | Type    | Default Value                   |
|--------------------------|---------------------------------------------------|---------|---------------------------------|
| username                 | Username                                          | string  | automatic                       |
| userUid                  | User UID                                          | string  | automatic                       |
| userGid                  | User GID                                          | string  | automatic                       |
| updateRc                 | Update RC files                                   | boolean | true                            |
| setTheme                 | Set theme for vim and zsh                         | boolean | true                            |
| vundleDir                | Vundle Install Path                               | string  | /usr/local/share/.vim/bundle    |
| antigenDir               | Antigen Install Path                              | string  | /usr/local/share/.zsh/bundle    |
| vimRcPath                | Path to the vimrc file                            | string  | /etc/vim/vimrc                 |
| zshRcPath                | Path to the zshrc file                            | string  | /etc/zsh/zshrc                 |
| bashRcPath               | Path to the bashrc file                           | string  | /etc/bash.bashrc               |
| javaVersion              | Java Version                                      | string  | lts                             |
| installGradle            | Install Gradle                                    | boolean | false                           |
| gradleVersion            | Gradle Version                                    | string  | latest                          |
| installMaven             | Install Maven                                     | boolean | false                           |
| mavenVersion             | Maven Version                                     | string  | latest                          |
| sdkmanInstallPath        | SDKMAN Install Path                               | string  | /usr/local/sdkman               |
| javaAdditionalVersions   | Additional Java Versions                          | string  | "" (empty string)                |
| pythonVersion            | Python Version                                    | string  | latest                          |
| pyenvInstallPath         | Pyenv Install Path                                | string  | /usr/local/pyenv                |
| pythonAdditionalVersions | Additional Python Versions                        | string  | "" (empty string)                |
| rubyVersion              | Ruby Version                                      | string  | latest                          |
| rbenvInstallPath         | Rbenv Install Path                                | string  | /usr/local/rbenv                |
| rubyAdditionalVersions   | Additional Ruby Versions                          | string  | "" (empty string)                |
| nodeVersion              | Node.js Version                                   | string  | latest                          |
| nvmInstallPath           | NVM Install Path                                  | string  | /usr/local/nvm                  |
| nodeAdditionalVersions   | Additional Node.js Versions                       | string  | "" (empty string)                |
| goVersion                | Go Version                                        | string  | latest                          |
| goInstallPath            | Go Install Path                                   | string  | /usr/local/go                   |
| goPath                   | Go Path                                           | string  | /go                             |
| exercismVersion          | Exercism Version                                  | string  | latest                          |
| terraformVersion         | Terraform Version                                 | string  | latest                          |

---
