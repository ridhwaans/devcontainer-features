
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
| vundleInstallPath        | Vundle Install Path                               | string  | /usr/local/share/.vim/bundle/Vundle.vim |
| antigenInstallPath       | Antigen Install Path                              | string  | /usr/local/share/.zsh/bundle    |
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
