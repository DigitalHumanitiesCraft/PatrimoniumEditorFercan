# Patrimonium Editor for Fercan
Project-specific adaptation of https://patrimonium.huma-num.fr/atlas/editor/

## Introduction

This document serves as a guide for users and developers involved in customising the Patrimonium Editor specifically for the Fercan project. The Fercan project, which focuses on the study of Celtic divine names in ancient inscriptions, uses the Patrimonium Editor to manage and analyse epigraphic data. This document outlines the scope of the customisation, introduces the project, and details the integration and extensions made to the Patrimonium Editor to meet the specific needs of the project.

The Fercan project is supported by the Austrian Science Fund (FWF) through grants P 29274-G25 and P 34422 G. It aims to explore Celtic divine names in the Roman provinces of Germania Inferior and Germania Superior, with a focus on understanding cultural interactions and religious dynamics during the Roman period. The research examines how local Celtic traditions were integrated into Roman practices, using epigraphic evidence to trace changes and continuities in religious expression.

## Customisation of the Patrimonium editor

The primary aim of customising the Patrimonium Editor is to enhance its ability to support the specific needs of the Fercan project.

## Patrimonium Editor

The Patrimonium Editor is an integrated suite of web applications tailored for academic and research use, focusing on the encoding, management and analysis of epigraphic and historical textual sources. Prior to customisation, it included an XML editor for accurate text encoding, text conversion tools that adhere to the Leiden Conventions, and data management capabilities for handling information about places, people, and thematic categories relevant to historical texts. It is designed to support a wide range of epigraphic documentation needs and is suitable for a variety of academic and research environments.

Its modular architecture not only provides considerable flexibility in terms of customisation, but also leverages the robust power of the eXist-db XML database. Structured to work with the TEI (Text Encoding Initiative) and EpiDoc (Epigraphic Documents) guidelines, the editor provides a robust framework for document encoding and data representation. This basic design allows it to be adapted to the specific needs of different research projects, ensuring that the Patrimonium Editor remains a versatile tool for scholars in the digital humanities.

### Core Components

**1.AusoHNum library:**.
- Functionality: Serves as the base library that provides backend functionality. It contains a collection of XQuery functions, JavaScript scripts and CSS stylesheets that enable and enhance the functionality of the front-end application and data repository.
- Content: This library contains reusable modules that handle various tasks such as data retrieval, transformation, presentation and interaction within the web application framework.

**2. Front-end application: eStudium**.
- Interface: The primary user interface where the actual interaction with the coded texts and datasets takes place. It is the main web application of eXist-db.
- Customisation: Provides project-specific settings such as customisation of TEI elements and templates, making it adaptable to the specific needs of different historical projects.
- Editor interface: Includes an easy-to-use XML editor that provides users with tools for encoding, editing, and wrapping text with XML elements in a visually accessible interface.

**3. Data repository: eStudiumData**.
- Data repository: Acts as a back-end application where all project-related data is stored. This includes TEI-coded texts, records of places and people, and thesaurus schemas.
- Management: Ensures data integrity and retrievability. It is optimised for efficient querying and manipulation of the XML data that is central to the function of the Patrimonium Editor.

### Functional Overview

**Text Editor**
- XML encoding: The text editor panel allows easy creation and editing of XML files, facilitating epigraphic text encoding by wrapping selected text with the necessary XML tags.
- Tools: Includes a number of additional editing tools such as search and replace, validation and formatting options to assist users in creating valid and well-structured TEI documents..

**Places Manager:**
- **Spatial Data**: Supports the creation and curation of spatial entities. It is designed to interact with place data models such as Pleiades and other ontologies that help connect, organise and relate spatial information.
- **Integration**: Links places to texts and other datasets within the Patrimonium framework, enabling multi-dimensional analysis of epigraphic data.

**People Manager:**
- **Prosopographical Data**: Manages the creation and curation of person-related data, using models such as SNAP:DRGN to describe historical figures, their attributes, and their relationships to one another.
- **Linkage**: Ensures that individuals mentioned in texts are accurately documented and linked, providing a comprehensive prosopographical dataset.

**Thesaurus Management:**
- **Controlled Vocabulary**: Handles thesaurus systems which provide controlled vocabularies for subjects, objects, and terms used within historical texts.
- **Standardization**: Aims to standardize the terminology used across documents, facilitating consistent tagging and easier retrieval of related texts.

**Zotero Integration:**
- **Bibliographic Data**: The editor integrates with Zotero, allowing users to manage references and bibliographic data directly within the application.
- **Synchronization**: Ensures that citations and sources are kept up-to-date and are easily accessible during the research and documentation process.

### Technical Infrastructure & Data Models

- **eXist-db**: A NoSQL XML database at the core of the Patrimonium Editor, responsible for storing, indexing, and querying XML data.
- **XML Standards**: Compliance with TEI and EpiDoc standards for encoding texts, ensuring that data conforms to internationally recognized guidelines in digital humanities.
- **Web Application**: The editor is accessible through a web browser, reducing the need for local installation and allowing for collaborative work across different locations.

**Data Models:**
- **Places Documents**: Based on Pleiades and NeoGeo spatial ontologies, enriched with connections described in SKOS and Dublin Core.
- **People Documents**: Modeled after Pleiades Place and SNAP:DRGN standards, also utilizing SKOS and Dublin Core for describing and relating individuals in historical texts.

### Libraries and Applications

#### AusoHNum Library
- **Purpose**: Essential for the Patrimonium project, this library contains XQuery and JavaScript functions, along with other resources needed to build the TEI/EpiDoc editor, places manager, and people manager.
- **Compatibility**: Designed to work with eStudium and eStudiumData.
- **Components**: Includes updates for modules, resources, templates and a build configuration (`build.xml`) as well as a collection configuration (`collection.xconf`).
    - **build.xml**: Ant build script to compile and package the library into a `.xar` deployment file for eXist-db.
    - **collection.xconf**: Configuration file for managing database collections in eXist-db, specifying indexing and storage options.
    - **controller.xql**: XQuery controller that routes requests to appropriate scripts or XQuery functions within the library.
    - **error-page.html**: HTML file that displays error information for the application.
    - **expath-pkg.xml**: Package descriptor for the library, defining dependencies and the structure for the eXist-db package manager.
    - **index.html**: Main HTML file, serving as the entry point for web-based interactions with the library’s functionalities.
    - **pre-install.xql**: XQuery script run before installation of the library to prepare the environment or check prerequisites.
    - **Various directories (data, modules, resources, templates, xslt)**: Contain the actual content, scripts, stylesheets, and XQuery modules that provide the library's functionality.

#### eStudium
- **Purpose**: Acts as a front-end application using the AusoHNum library.
- **Functionality**: Works in conjunction with eStudiumData, which stores the data required by this front-end.
- **Components**: Contains updates similar to those in the AusoHNum Library, including resources, templates and necessary configuration files for deployment.
    - **.existdb.json**: Configuration file for eXist-db specific to the eStudium application, possibly including settings for the database connection and setup.
    - **build.xml, collection.xconf, controller.xql, error-page.html, expath-pkg.xml, index.html, pre-install.xql, repo.xml**: Similar to those in AusoHNum Library, tailored for the front-end application.

#### eStudiumData
- Purpose: Serves as a data repository application supporting the eStudium front-end.
- **Components**: Hosts directories for various types of data and metadata such as `biblio`, `concepts`, `documents`, and contains configuration and deployment files similar to those found in other directories. Store specific types of data and metadata, scripts, and configuration files necessary for managing and organizing the stored data according to the project's requirements.


The adaptation of the Patrimonium Editor for the Fercan project involves several key customizations and enhancements to meet the specialized needs of the research focused on Celtic divine names in ancient inscriptions. Below is a detailed guide and overview of the enhancements, followed by a new resources section that directs users to further information about the Patrimonium Editor.

## Customization and Integration Details

### Customization Scope

The Fercan project's customization of the Patrimonium Editor specifically aims to support the detailed study of Celtic divine names found in the Roman provinces of Germania Inferior and Germania Superior. This involves tailoring the editor to handle specific epigraphic data formats and integrating tools that facilitate the analysis of cultural and religious shifts evident in these inscriptions.

### Technical Enhancements

- **XML Editor Enhancements**: Adaptations to the XML editor to include specific tagging conventions unique to Celtic deity names and their associated descriptions.
- **Leiden Conventions**: Customized text conversion tools have been developed to adhere to and extend the Leiden Conventions specifically for the scripts and languages found in the targeted inscriptions.
- **Data Management Features**: Enhancements to manage and visualize relationships between deities, inscriptions, and geographic locations. This includes improved mapping tools and visualization features that are integrated with the existing database management system.

### Integration with Existing Systems

- **Integration with eXist-db**: The enhanced Patrimonium Editor remains compatible with the eXist-db, leveraging its capabilities for robust data storage and retrieval. Custom scripts and configurations have been optimized for performance with large datasets typical of epigraphic studies.
- **Use of AusoHNum Library**: The customized editor utilizes the AusoHNum Library for backend operations, ensuring seamless integration and functionality across different components of the project.

## Resources

- **General Overview**:
  - A general presentation of the Patrimonium Editor was given at the epigraphy.info IV workshop in Hamburg on February 20, 2020. [Download the presentation (2.03 MB)](https://patrimonium.huma-num.fr/atlas/editor/presentations/epigraphy_info_IV_2020.pdf)
- **Handling of Spatial Information**:
  - A presentation focused on the handling of spatial information by the Patrimonium Editor was showcased at the Assises MAGIS 2020 (online) on June 24, 2020. [Download the presentation (2.6 MB)](https://patrimonium.huma-num.fr/atlas/editor/presentations/assises_MAGIS_2020.pdf)
- **Recent Developments**:
  - A poster highlighting recent developments and features of the Patrimonium Editor was presented at the epigraphy.info V workshop in Leuven (online) on November 5, 2020. [Download the poster (1.245 MB)](https://patrimonium.huma-num.fr/atlas/editor/presentations/epigraphy_info_V_2020.pdf)
