"""Dependency-free structural CI checks that run before the macOS build."""
import pathlib
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ProjectIntegrityTests(unittest.TestCase):
    def test_pbxproj_registers_all_swift_sources(self):
        project = (ROOT / "GeoLab.xcodeproj" / "project.pbxproj").read_text()
        for source in sorted((ROOT / "GeoLab").glob("*.swift")):
            self.assertIn(f"path = {source.name};", project)
            self.assertIn(f"{source.name} in Sources", project)

    def test_no_unsigned_ipa_claims_installability(self):
        workflow = (ROOT / ".github" / "workflows" / "ios-build.yml").read_text()
        self.assertIn("CODE_SIGNING_ALLOWED=NO", workflow)
        self.assertIn("UNSIGNED", workflow)
        self.assertIn("macos-15", workflow)

    def test_example_gpx_has_coordinates(self):
        example = ROOT / "Examples" / "Makkah_Test.gpx"
        root = ET.parse(example).getroot()
        points = [node for node in root.iter() if node.tag.endswith("trkpt") or node.tag.endswith("rtept")]
        self.assertGreaterEqual(len(points), 2)
        for point in points:
            lat, lon = float(point.attrib["lat"]), float(point.attrib["lon"])
            self.assertLessEqual(abs(lat), 90)
            self.assertLessEqual(abs(lon), 180)

    def test_no_hidden_location_permissions(self):
        project = (ROOT / "GeoLab.xcodeproj" / "project.pbxproj").read_text()
        self.assertNotIn("NSLocationAlwaysAndWhenInUseUsageDescription", project)
        self.assertNotIn("com.apple.developer.networking.networkextension", project)


if __name__ == "__main__":
    unittest.main()
