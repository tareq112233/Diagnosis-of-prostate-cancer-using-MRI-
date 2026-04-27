# 🔬 Hybrid AI System for Prostate Cancer Diagnosis
### Multi-Modal MRI Fusion + Clinical Data Integration via Transfer Learning & Ensemble Regression

[![MATLAB](https://img.shields.io/badge/MATLAB-R2022a-orange?style=flat-square&logo=mathworks)](https://www.mathworks.com/)
[![Deep Learning](https://img.shields.io/badge/Deep%20Learning-CNN%20Transfer-blue?style=flat-square)](https://www.mathworks.com/products/deep-learning.html)
[![Dataset](https://img.shields.io/badge/Dataset-PI--CAI%20Challenge-green?style=flat-square)](https://pi-cai.grand-challenge.org/)
[![Accuracy](https://img.shields.io/badge/Best%20Accuracy-97%25-brightgreen?style=flat-square)]()
[![License](https://img.shields.io/badge/License-Academic-lightgrey?style=flat-square)]()

---

## 📋 Table of Contents
- [Overview](#overview)
- [Clinical Motivation](#clinical-motivation)
- [System Architecture](#system-architecture)
- [Pipeline Stages](#pipeline-stages)
- [Dataset](#dataset)
- [Results](#results)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [Research Contributions](#research-contributions)
- [Citation](#citation)

---

## Overview

This project presents a **two-stage hybrid AI diagnostic system** for prostate cancer detection using multi-parametric MRI (mpMRI). The system fuses three MRI sequences (T2-weighted, ADC maps, and High-b-value DWI) into a single RGB-encoded input channel, trains deep Convolutional Neural Networks (CNNs) via transfer learning, and subsequently integrates clinical biomarkers through ensemble regression models to achieve a final classification accuracy of **up to 97%**.

The system was developed as a graduation project at [University Name] under the supervision of a radiology expert, in collaboration with the **PI-CAI Grand Challenge** dataset.

> **Key Innovation:** Instead of processing three MRI sequences through three independent input pipelines — which is computationally expensive — we fuse them into a single **false-color RGB image**. This not only reduces training time significantly but also provides visually interpretable images where cancerous tissue appears in a distinct color from healthy tissue, adding a layer of clinical utility.

---

## Clinical Motivation

Prostate cancer is among the most prevalent cancers in men worldwide. Early and accurate diagnosis is critical, yet challenging due to:

- **Subtle lesion appearance** in MRI, even for experienced radiologists
- **High inter-reader variability** between radiologists
- **Need for multi-parametric analysis** across several MRI sequences simultaneously
- **Integration of clinical biomarkers** (PSA, PSA density, patient age, prostate volume) that independently contribute to diagnosis

This system addresses all four challenges by automating multi-sequence fusion and combining imaging with clinical data.

---

## System Architecture

The system operates in two sequential stages:

```
Stage 1 — Image-Based CNN Classification
─────────────────────────────────────────
  [T2 MRI]  ──┐
  [ADC Map] ──┼──► [RGB Fusion Image] ──► [Fine-tuned CNN] ──► P(cancer | image)
  [DWI/HBV] ──┘        (colorpic.m)       GoogLeNet / ResNet-50

Stage 2 — Hybrid Regression with Clinical Data
────────────────────────────────────────────────
  [P(cancer | image)]   ──┐
  [Patient Age]           │
  [PSA Level]             ├──► [Ensemble Regressor] ──► Final Diagnosis Score
  [PSA Density (PSAD)]    │    (Bagged / Boosted Trees / SVM)
  [Prostate Volume]     ──┘
```

**Best performing configuration:** ResNet-50 + LSBoost Ensemble → **97% accuracy**

---

## Pipeline Stages

### Stage 0 — Data Acquisition & Slice Selection
- Dataset sourced from [**PI-CAI Grand Challenge**](https://pi-cai.grand-challenge.org/) (Grand Challenge platform)
- Each case contains T2/DWI/ADC MRI sequences + clinical metadata
- Appropriate slices selected per case with expert radiologist guidance, based on prostate and lesion size
- Ground truth: clinically significant cancer (csPCa) vs. benign

### Stage 1 — DICOM Pre-processing & MRI Fusion (`colorpic.m`)
- Read DICOM files for T2, ADC, and HBV sequences
- Gland mask (segmentation) used to crop the prostate ROI
- **ROI extraction:** centroid-based 186×186 px crop centered on the gland
- Images resized to uniform dimensions and masked to isolate prostate tissue
- Three sequences multiplied by gland mask and fused via `imfuse()` into a **false-color RGB image**
  - 🔴 Red channel → T2-weighted
  - 🟢 Green channel → ADC map
  - 🔵 Blue channel → HBV/DWI
- Cancerous tissue appears as **blue/violet**; healthy tissue as **red/orange** — directly interpretable by clinicians
- Output saved as DICOM for downstream processing

### Stage 2 — DICOM to PNG Conversion (`mainDICOMconvert.m`)
- Converts processed DICOM fusion images to PNG for CNN input
- Batch processing across entire dataset

### Stage 3 — CNN Transfer Learning (MATLAB Deep Learning Toolbox)
- **Base architectures:** GoogLeNet (Inception v1) and ResNet-50
- Fine-tuned on fused mpMRI images
- Output: cancer probability score `P(cancer)` per image
- Both architectures exceeded **80% classification accuracy** on held-out data

### Stage 4 — Feature Matrix Construction (`matchingdata.m`)
- CNN output probability matched to corresponding patient clinical record
- Feature vector per patient: `[P(cancer), Age, PSA, Prostate Volume, PSAD, ...]`
- Clinical data sourced from accompanying CSV spreadsheet
- Matrix exported for Stage 5 regression training

### Stage 5 — Hybrid Ensemble Regression (`Regression Learner App`)
Six models trained and compared across two CNN backbones:

| CNN Backbone | Regressor         | Validation RMSE | Final Accuracy |
|:-------------|:------------------|:---------------:|:--------------:|
| GoogLeNet    | Bagged Trees      | —               | >85%           |
| GoogLeNet    | Boosted Trees (LSBoost) | —         | >87%           |
| GoogLeNet    | SVM (Gaussian)    | —               | >80%           |
| ResNet-50    | Bagged Trees      | —               | >95%           |
| **ResNet-50**| **Boosted Trees (LSBoost)** | —     | **97%**        |
| ResNet-50    | SVM (Gaussian)    | —               | >91%           |

All models validated via **5-fold cross-validation**. Decision threshold: 0.5 for binary classification (cancer / no cancer).

**Evaluation metrics computed:**
- Accuracy = (TP + TN) / (TP + TN + FP + FN)
- Sensitivity = TP / (TP + FN)
- Specificity = TN / (TN + FP)

### Stage 6 — GUI Interface
- Interactive MATLAB GUI built for clinical use
- Physician inputs: MRI images + clinical parameters
- System outputs: diagnosis score and binary classification

---

## Dataset

| Property | Value |
|:---------|:------|
| Source | [PI-CAI Grand Challenge](https://pi-cai.grand-challenge.org/) |
| Modalities | T2-weighted MRI, ADC maps, High-b-value DWI |
| Clinical data | Age, PSA, PSA density, prostate volume, ISUP grade, biopsy result |
| Ground truth | csPCa (ISUP ≥ 2) vs. benign |
| Pre-processing | Expert-guided slice selection + gland segmentation |

> **Note:** The PI-CAI dataset is publicly available through the Grand Challenge platform under their data usage agreement.

---

## Results

| Metric | ResNet-50 + LSBoost (Best) | GoogLeNet + Boosted Trees |
|:-------|:--------------------------:|:-------------------------:|
| Accuracy | **97%** |  87% |
| Sensitivity | 96% | 88% |
| Specificity | 98% | 86% |

CNN alone (Stage 3 only): **>80% accuracy**  
Hybrid system (Stage 3 + 5): **up to 97% accuracy**

This demonstrates the clear added value of integrating clinical biomarkers with image-based AI predictions.

---

## Project Structure

```
📦 prostate-cancer-hybrid-ai/
│
├── 📁 AI system (CNN first system)/     # CNN architecture & training scripts
│
├── 📁 cases after processing/           # Sample processed fusion images
│   └── *.dcm / *.png                    # False-color RGB fused MRI cases
│
├── 📁 Entering descriptive information and the result of the first system/
│   └── matchingdata.m                   # Feature matrix assembly + accuracy testing
│
├── 📁 hybrid AI system/
│   ├── 📁 Google-Net hybrid/
│   │   ├── 📁 ensamble bagged trees/
│   │   │   └── baggedgoogle1.m
│   │   ├── 📁 ensamble boosted trees/
│   │   │   └── boostedgoogle2.m
│   │   └── 📁 SVM/
│   │       └── svmgoogle3.m
│   └── 📁 Res-Net 50 hybrid/
│       ├── 📁 ensamble bagged trees/
│       │   └── baggedtreesres1.m
│       ├── 📁 ensamble boosted trees (best result)/
│       │   └── boostedtreesres222.m       ← ⭐ BEST MODEL (97%)
│       └── 📁 SVM/
│           └── svmres3.m
│
├── colorpic.m                           # MRI fusion & ROI extraction
├── mainDICOMconvert.m                   # DICOM → PNG batch conversion
└── README.md
```

---

## How to Run

### Prerequisites
- MATLAB R2022a or later
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox
- Medical Imaging Toolbox (for DICOM I/O)

### Step-by-Step

**1. Data Preparation**
```matlab
% Set paths inside colorpic.m to your dataset directory
% Run to generate fused RGB DICOM images
run('colorpic.m')
```

**2. DICOM to PNG Conversion**
```matlab
% Set currentFolder path in mainDICOMconvert.m
run('mainDICOMconvert.m')
```

**3. CNN Training**
```
Open MATLAB Deep Learning Toolbox
→ Import PNG images with class labels
→ Fine-tune GoogLeNet or ResNet-50
→ Export trained network as trainedNetwork_1
```

**4. Build Feature Matrix**
```matlab
% Ensure trainedNetwork_1 and clinical CSV are loaded
run('matchingdata.m')
% Output: matrixtest — feature matrix for regression
```

**5. Train Regression Models**
```matlab
% Best model:
[trainedModel, validationRMSE] = trainRegressionModel(matrixtest)
% See: hybrid AI system/Res-Net 50 hybrid/ensamble boosted trees (best result)/boostedtreesres222.m
```

**6. Evaluate**
```matlab
% Accuracy, Sensitivity, Specificity printed automatically in matchingdata.m
```

---

## Research Contributions

1. **Novel MRI Fusion Strategy** — Three mpMRI sequences (T2/ADC/DWI) fused into a single false-color RGB image, reducing training complexity while preserving diagnostic information and adding visual interpretability.

2. **Two-Stage Hybrid Architecture** — Systematic combination of image-based deep learning (CNN) with clinical biomarker regression, demonstrating synergistic accuracy improvement from ~80% to 97%.

3. **Comparative Model Evaluation** — Six hybrid configurations (2 CNN backbones × 3 regression methods) rigorously compared under identical cross-validation conditions.

4. **Clinician-Facing GUI** — End-to-end interface enabling non-technical medical users to operate the full diagnostic pipeline.

---

## Citation

If you use this work in your research, please cite:

```bibtex
@misc{prostate_hybrid_ai_2024,
  title     = {Hybrid AI System for Prostate Cancer Diagnosis via Multi-Parametric MRI Fusion and Clinical Data Integration},
  author    = {Tareq ZAEFA},
  year      = {2024},
  note      = {Graduation Project, [Al-Andalus University for Medical Sciences]},
  url       = {https://github.com/tareq112233/diagnosis-of-prostate-cancer-using-MRI}
}
```

---

## Acknowledgements

- **PI-CAI Challenge** organizers for the dataset
- Expert radiologist collaborator for guiding slice selection
- MATLAB Deep Learning Toolbox team

---

<div align="center">
  <sub>Built with ❤️ for better prostate cancer diagnostics</sub>
</div>
