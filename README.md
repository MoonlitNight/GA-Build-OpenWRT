# OpenWRT Automated Build with GitHub Actions

This project automates the building of OpenWRT firmware images using GitHub Actions, allowing for easy customization and deployment.

## Project Description

This repository provides a complete workflow to:
- Automatically build OpenWRT firmware images
- Fetch the latest releases of specified repositories
- Convert images to qcow2 format for virtual machine usage

## Project Structure
```
├── .github/
│ ├── actions/
│ └── get-latest-tags/
│ │ └── action.yml # Action to fetch latest release tags from specified repos
│ └── workflows/
│ └── openwrt_builder_run.yml # Main build workflow
├── img2qcow.sh # Script to convert img.gz to qcow2 format
└── *.config # OpenWRT configuration files (generated via make menuconfig)
```


## Key Features

1. **Automated Build Workflow**:
    - Located in `.github/workflows/openwrt_builder_run.yml`
    - Fully automated build process triggered by GitHub Actions
    - Customizable with additional packages as needed

2. **Build Cache Optimization**:
    - Utilizes GitHub Actions Cache to store build dependencies
    - Subsequent builds are significantly faster by reusing cached components
    - Cache is automatically invalidated when configuration changes

3. **Latest Release Fetcher**:
    - Action located at `.github/actions/get-latest-tags/action.yml`
    - Automatically retrieves the latest release versions from specified repositories

4. **Image Conversion**:
    - `img2qcow.sh` converts compressed OpenWRT images (.img.gz) to qcow2 format
    - Ideal for virtualization platforms like QEMU/KVM

5. **Configuration**:
    - Uses standard OpenWRT `.config` files
    - Generate your configuration with [make menuconfig](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
    - Commit your config file to customize your build

## Usage

1. **Configure Your Build**:
    - Add your desired packages and configuration
    - Generate your `.config` file using `make menuconfig`
    - Commit your configuration file to the repository
    - Adjust the config file path in `.github/workflows/openwrt_builder_run.yml` if needed.

2. **Run the Build Process**:
    - The workflow will automatically:
        - Fetch the latest OpenWRT sources
        - Build the image using your configuration
        - Convert the output image to qcow2 format by default
        - Store both original and converted images as workflow artifacts
    - First build will be slower as it populates the cache
    - Subsequent builds will use cached components for faster execution
    - Results can be downloaded from the GitHub Actions artifacts section

### Important Setup Note:
Before your first build, you must configure the workflow permissions:
1. Go to your repository **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - **Read and write permissions**
3. This allows the workflow to:
   - Automatically create releases when builds succeed
   - Upload build artifacts
## Customization

- Add your own packages by modifying the configuration
- Adjust build parameters in the workflow file
- Extend functionality by modifying the GitHub Actions
- Cache behavior can be configured in the workflow file

## Requirements

- GitHub account
- Basic understanding of OpenWRT configuration
- Basic understanding of GitHub Action

## License

[MIT License](LICENSE)
