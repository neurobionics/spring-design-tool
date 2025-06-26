# Spring Design Tool

A powerful software tool designed to facilitate the creation of lightweight torsion springs.

<div align="center">
  <img src="assets/Design Tool Snip.png" width="500" alt="Design Tool Interface"/>
  <img src="assets/spring GIF.gif" width="290" alt="Spring Design Animation"/>
</div>

## 📥 Download

Get the [latest release](https://github.com/neurobionics/spring-design-tool/releases).

## 🚀 Installation

### For MATLAB Users

- Ensure you have a MATLAB license.
- Install the Design Tool as a custom MATLAB App through **APPS > Install App**.

### Without MATLAB License

- Compatible with PCs.
- Open the `.exe` file to install the Design Tool as a desktop application.

## 🛠️ Usage

- Hover over labels or data fields for explanations of each input.
- For 'Optional' arguments, inputting 0 lets the tool calculate values automatically.
- Once inputs are set, click **Create Spring** to generate your custom design.
- For optimal performance, enter a 'Run Time' of 15-30 seconds.
- If satisfied with the design, select your output 'File Type' and 'Units' and click **Download Design**.
  - Choose the 'File Type' based on your CAD software (e.g., `.txt` for Solidworks, `.csv` for Fusion360 and Onshape).

## 🧩 Create Solid Model

- The tool outputs xyz-coordinates for your spring design with various curve options.
- Check the `README_profile_descriptions` in the output folder for detailed explanations.
- Import the curves into your CAD software to create 3D models. Search for tutorials using "CAD_SOFTWARE_NAME curve through xyz points" for guidance.

## 📚 Examples

If unfamiliar with designing springs or unsure of suitable stiffness/deflection ranges, explore these literature examples of spring radius, thickness, stiffness, and deflection:

- **dos Santos et al. '15**: 62.5 mm, 6 mm, 150 Nm/rad, 5.73°
- **Carpino et al. '12**: 42.5 mm, 3 mm, 92 Nm/rad, 4.76°
- **Georgiev et al. '17**: 74 mm, 9.5 mm, 600 Nm/rad, 20°
- **Tsagarakis et al. '09**: 35 mm, 10 mm, 153 Nm/rad, 10°
- **Lagoda et al. '10**: 37.5 mm, 15 mm, 353 Nm/rad, 16.23°
- **Wang et al. '13**: 41.5 mm, 10.5 mm, 800 Nm/rad, 7.16°
