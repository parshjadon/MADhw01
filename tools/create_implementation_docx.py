from __future__ import annotations

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
import html


OUT = Path("YourName_Implementation.docx")


def esc(text: str) -> str:
    return html.escape(text, quote=True)


def paragraph(text: str = "", style: str | None = None, bold: bool = False) -> str:
    style_xml = f'<w:pStyle w:val="{style}"/>' if style else ""
    bold_xml = "<w:b/>" if bold else ""
    return (
        "<w:p>"
        f"<w:pPr>{style_xml}</w:pPr>"
        "<w:r>"
        f"<w:rPr>{bold_xml}</w:rPr>"
        f'<w:t xml:space="preserve">{esc(text)}</w:t>'
        "</w:r>"
        "</w:p>"
    )


def bullet(text: str) -> str:
    return paragraph(f"- {text}")


def document_xml() -> str:
    sections: list[str] = [
        paragraph("Calculator App Implementation Rationale", "Title"),
        paragraph("Name: TODO Replace with your name"),
        paragraph("Student ID: TODO Replace with your student ID"),
        paragraph("Course: CSC 6370 Graduate"),
        paragraph("Selected features: Decimal support, calculation history, advanced operations, backspace/delete"),
        paragraph(
            "This document explains the calculator app built for Assignment 01. "
            "The app implements the required two operand arithmetic flow and three "
            "undergraduate pathway features. It also records the main design decisions, "
            "test evidence, and remaining submission fields that must be completed "
            "with the student's own information."
        ),
        paragraph("Implementation Summary", "Heading1"),
        paragraph(
            "The Flutter app replaces the generated counter starter with a Material 3 "
            "calculator. The main state values are the display text, first operand, "
            "pending operator, a flag that controls whether the next digit replaces "
            "the display, and an optional error message. The UI updates through "
            "setState so the visible display always reflects the calculator state."
        ),
        paragraph("Core Requirements", "Heading1"),
        bullet("Number buttons 0 through 9 are available in a fixed button grid."),
        bullet("Addition, subtraction, multiplication, and division are implemented."),
        bullet("The display shows current input, results, pending operation status, and recoverable errors."),
        bullet("The app uses reusable widgets for the calculator panel, button grid, and individual buttons."),
        bullet("The layout is constrained for phones and wider screens, with stable button sizing and text scaling."),
        paragraph("Graduate Requirement Decimal Support", "Heading1"),
        paragraph(
            "The app contains a switch in the app bar that toggles between light and dark themes. "
            "The root CalculatorApp stores the theme mode and passes the selected value down to the screen. "
            "The app uses separate ColorScheme.fromSeed values for light and dark modes so all calculator "
            "surfaces, buttons, and display colors update together."
        ),
        paragraph("Selected Feature 1 Calculation History", "Heading1"),
        paragraph(
            "The AC button resets all calculator state, including display text, first operand, pending operator, "
            "digit replacement behavior, and error messages. The CE button clears only the current entry and keeps "
            "the pending operation available. This gives the user a predictable way to recover from input mistakes."
        ),
        paragraph("Selected Feature 2 Advanced Operations", "Heading1"),
        paragraph(
            "The app validates incomplete calculations and division by zero. Pressing equals without a complete "
            "operation shows a helpful message instead of crashing or silently doing nothing. Division by zero "
            "sets the display to Error and explains that AC starts again."
        ),
        paragraph("Selected Feature 3 Backspace and Delete", "Heading1"),
        paragraph(
            "The calculator stores only values that change because of user actions: display text, first operand, "
            "pending operator, whether the next digit should replace the display, and an optional error message. "
            "The selected status text is derived from those values. This keeps the state small and prevents a "
            "separate result value from drifting out of sync with the display."
        ),
        paragraph("Question 02 Correctness Under Pressure", "Heading1"),
        paragraph(
            "The most important correctness cases are normal arithmetic, replacing the display after an operator, "
            "clearing state, incomplete input, and division by zero. Widget tests cover addition, fractional division, "
            "all clear, division by zero recovery, and theme switching."
        ),
        paragraph("Question 03 Accessibility Is Behavior", "Heading1"),
        paragraph(
            "The display uses a Semantics label and liveRegion so assistive technology can identify the displayed "
            "value. Buttons use semantic labels such as Add, Subtract, Multiply, Divide, All clear, and Clear entry "
            "instead of relying only on symbols."
        ),
        paragraph("Question 04 Performance Without Visual Loss", "Heading1"),
        paragraph(
            "The app avoids expensive work during build. Arithmetic is simple Dart control flow, and layout is made "
            "from standard Material widgets. FittedBox is used only where text might otherwise overflow, preserving "
            "readability without custom paint or unnecessary animation work."
        ),
        paragraph("Question 05 AI Output Under Review", "Heading1"),
        paragraph(
            "TODO: Paste the unchanged prompts and short summaries from two real AI agents here. "
            "Verify at least one claim using the Flutter app behavior or widget tests. A good verification claim "
            "for this project is that division by zero should produce a recoverable error, which is tested in "
            "test/widget_test.dart."
        ),
        paragraph("Question 06 AI Advice Trade Offs and Maintainability", "Heading1"),
        paragraph(
            "Advice from an AI agent should be checked against assignment requirements and actual app behavior. "
            "For example, a suggestion to add many advanced features might look impressive but could distract from "
            "the graduate requirement to implement decimals and explain three selected advanced features. The implementation favors clear "
            "state and focused tests over extra calculator modes."
        ),
        paragraph("AI Agent Test Drive Template", "Heading1"),
        paragraph("Prompt used unchanged: TODO Paste Agent Test prompt 01, 02, or 03."),
        paragraph("Agent 1 and date: TODO"),
        paragraph("Agent 1 useful claim: TODO"),
        paragraph("Agent 2 and date: TODO"),
        paragraph("Agent 2 useful claim: TODO"),
        paragraph("Verified claim and evidence: TODO Reference a manual test or widget test."),
        paragraph("Testing Evidence", "Heading1"),
        bullet("flutter analyze completed with no issues."),
        bullet("flutter test completed with all graduate feature widget tests passing."),
        bullet("Test cases cover decimal input, duplicate decimal prevention, fractional division, percent, square root, sign toggle, delete, history reuse, division by zero recovery, and theme toggle."),
        paragraph("Submission Checklist", "Heading1"),
        bullet("Replace TODO name and student ID in this document."),
        bullet("Replace github_link.txt with the real GitHub repository URL."),
        bullet("Build the APK with flutter build apk and rename it to YourName_CalculatorApp.apk."),
        bullet("Upload the repository link, renamed APK, and final DOCX to the course LMS."),
    ]

    body = "\n".join(sections)
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    {body}
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
'''


CONTENT_TYPES = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'''

RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'''

DOC_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>
'''

STYLES = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="160" w:line="276" w:lineRule="auto"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="260"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="000000"/><w:sz w:val="36"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:keepNext/><w:spacing w:before="280" w:after="120"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="000000"/><w:sz w:val="28"/></w:rPr>
  </w:style>
</w:styles>
'''


def main() -> None:
    with ZipFile(OUT, "w", ZIP_DEFLATED) as docx:
        docx.writestr("[Content_Types].xml", CONTENT_TYPES)
        docx.writestr("_rels/.rels", RELS)
        docx.writestr("word/_rels/document.xml.rels", DOC_RELS)
        docx.writestr("word/document.xml", document_xml())
        docx.writestr("word/styles.xml", STYLES)
    print(OUT)


if __name__ == "__main__":
    main()
