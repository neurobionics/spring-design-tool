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

## 📄 Outputs

The tool outputs xyz-coordinates for your spring design with various curve options:
- **Raw**: The precise spline of one flexure as optimized by the tool (no added tip or fillets).
- **Pattern**: The raw spline of one flexure, but with circular tip and fillets added.
- **Wedge**: A single wedge-slice of the full spring geometry (includes outer rim/dowel hole).
- **Inner**: The inner curve of the full spring, including all flexures, tips, and fillets.
- **Outer**: The outer curve of the full spring with all semi-circular cutouts for the dowels.
- **Cam_profile**: The complete curve of the camshaft, including all gear-like teeth.

If you forget which settings you selected for your spring design, check `README_spring_properties` in the output folder!

## 🧩 Create Solid Model

<details>
<summary><strong>🔧 CAD Selection</strong></summary>

Use the following resources to import the spring geometry:
  - **SolidWorks**: [Curves Through XYZ Points](https://help.solidworks.com/2021/english/SolidWorks/sldworks/hidd_curve_in_file.htm)
  - **OnShape**: [3D XYZ CSV Points and Splines](https://cad.onshape.com/documents/a5566bc4a7c123d4958fd925/v/74ef42fd67330626670210c7/e/07d3a8c9750bc033aa654b39)
  - **Other**: Search for tutorials using "CAD_SOFTWARE_NAME curve through xyz points" for guidance.

</details>

<details>
<summary><strong>⚡ Quick Model</strong></summary>
  
- **Spring**:
  - Import `inner` and `outer` using your preferred CAD package.
  - Start a sketch on the same plane and pull both curves into the sketch.
  - Extrude the enclosed area.
- **Cam**:
  - Import `cam_profile` and extrude.

</details>

<details>
<summary><strong>🔍 Detailed Model</strong></summary>
  
- **Spring**: 
  - Import `raw` using your preferred CAD package.
  - Start a sketch on the same plane and pull the raw curve into the sketch.
  - Sketch the rim wedge to close the open end of the flexure.
  - Extrude the enclosed area.
  - Sketch and extrude the flexure tip according to 'tip radius' and 'contact radius' as defined in `README_spring_properties`.
  - Add fillets at the tip geometry (same radius as 'tip radius') and flexure root (approximately 1/4 the thickness of the flexure base).
  - Use circular patterning to duplicate the model based on the number of flexures (n) defined in `README_spring_properties`.
- **Cam**:
  - Import `cam_raw` and pull the curve into a new sketch on the same plane.
  - Sketch the root geometry allowing clearance for the flexure tip.
  - Close the rest of the sketch.
  - Extrude.
  - Mirror the body across the centerline of the flexure.
  - Use circular patterning for the cam by the number of flexures (n) defined in `README_spring_properties`.

</details>

## 📚 Examples

If unfamiliar with designing springs or unsure of suitable stiffness/deflection ranges, explore these literature examples of spring radius, thickness, stiffness, and deflection:

- **dos Santos et al. '15**: 62.5 mm, 6 mm, 150 Nm/rad, 5.73°
- **Carpino et al. '12**: 42.5 mm, 3 mm, 92 Nm/rad, 4.76°
- **Georgiev et al. '17**: 74 mm, 9.5 mm, 600 Nm/rad, 20°
- **Tsagarakis et al. '09**: 35 mm, 10 mm, 153 Nm/rad, 10°
- **Lagoda et al. '10**: 37.5 mm, 15 mm, 353 Nm/rad, 16.23°
- **Wang et al. '13**: 41.5 mm, 10.5 mm, 800 Nm/rad, 7.16°
