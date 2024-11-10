
# Base

A devcontainer feature

## Example Usage

```json
"features": {
    "ghcr.io/ridhwaans/devcontainer-features/base:latest": {
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
| vundleDir                | Vundle Install Path                               | string  | /usr/local/share/vim/bundle     |
| antigenDir               | Antigen Install Path                              | string  | /usr/local/share/zsh/bundle     |
| vimRcPath                | Path to the vimrc file                            | string  | ~/.vimrc                        |
| zshRcPath                | Path to the zshrc file                            | string  | ~/.zshrc                        |
| bashRcPath               | Path to the bashrc file                           | string  | ~/.bashrc                       |
| javaVersion              | Java Version                                      | string  | lts                             |
| installGradle            | Install Gradle                                    | boolean | false                           |
| gradleVersion            | Gradle Version                                    | string  | latest                          |
| installMaven             | Install Maven                                     | boolean | false                           |
| mavenVersion             | Maven Version                                     | string  | latest                          |
| sdkmanPath               | SDKMAN Install Path                               | string  | /usr/local/sdkman               |
| javaAdditionalVersions   | Additional Java Versions                          | string  | "" (empty string)               |
| pythonVersion            | Python Version                                    | string  | latest                          |
| pyenvPath                | Pyenv Install Path                                | string  | /usr/local/pyenv                |
| pythonAdditionalVersions | Additional Python Versions                        | string  | "" (empty string)               |
| rubyVersion              | Ruby Version                                      | string  | latest                          |
| rbenvPath                | Rbenv Install Path                                | string  | /usr/local/rbenv                |
| rubyAdditionalVersions   | Additional Ruby Versions                          | string  | "" (empty string)               |
| nodeVersion              | Node.js Version                                   | string  | latest                          |
| nvmPath                  | NVM Install Path                                  | string  | /usr/local/nvm                  |
| nodeAdditionalVersions   | Additional Node.js Versions                       | string  | "" (empty string)               |
| goVersion                | Go Version                                        | string  | latest                          |
| goDir                    | Go Install Path                                   | string  | /usr/local/go                   |
| goPath                   | Go Path                                           | string  | /go                             |
| exercismVersion          | Exercism Version                                  | string  | latest                          |
| terraformVersion         | Terraform Version                                 | string  | latest                          |
| newPassword              | New Password                                      | string  | skip                            |
| sshdPort                 | Sshd Port                                         | string  | 2222                            |
| startSshd                | Start Sshd                                        | string  | false                           |

---
