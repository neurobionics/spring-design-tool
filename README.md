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
- Double-click on `spring_design_tool.mlappinstall` ([found here](https://github.com/neurobionics/spring-design-tool/releases)).
- Open MATLAB and find the tool under `My Apps`.

### Without MATLAB License

- Compatible with PCs.
- Open the `DesignToolStandalone` zip folder
- Check the `readme`.
- Double-click `spring_design_tool` to install and open the Design Tool as a desktop application.

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
- **Cam_raw**: The curve of the contact surface (no fillets or extra geometry).

If you forget which settings you selected for your spring design, check `README_spring_properties` in the output folder!

## 🧩 Create Solid Model

### For OnShape Users (recommended)

- Ensure you downloaded the curves as `.csv` files with `m` for units.
- Copy [this template](https://cad.onshape.com/documents/ca804b1fdb50c919aa2737f1/w/f0c25649eb1bf60ca8ba5e0b/e/71a2f57b2c3e3aa6a4f81394) to your preferred OnShape folder.
- Import `raw_m.csv` and `cam_raw_m.csv` to your copied workspace.
- In the Variable Studio, update workspace variables with the values found in `README_spring_properties` (in the output folder).
- In the Part Studio feature tree, edit `Cam_Raw CSV` and `Raw CSV` by updating their respective tables to reference your new `.csv` files.
- Open the first sketch (`Spring & Cam Geometry`) and resolve errors:
  - Delete curves with broken relationships.
  - Click on new curves and convert to sketch (`u`).
  - Make any adjustments to ensure the geometry is closed.
- Exit the sketch and resolve any final details (the fillets often lose their reference).
- Make any custom modifications you'd like!

### For Other CAD Software

You will need the following resources to import the spring geometry:
  - **SolidWorks**: [Curves Through XYZ Points](https://help.solidworks.com/2021/english/SolidWorks/sldworks/hidd_curve_in_file.htm)
  - **Fusion 360**: ImportSplineCSV (UTILITIES > ADD-INS > Scripts and Add-Ins)
  - **Other**: Search for tutorials using "CAD_SOFTWARE_NAME curve through xyz points" for guidance.

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
  - Add fillets at the tip geometry (same radius as 'tip radius') and flexure root (approximately 1/2 the rim thickness).
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
