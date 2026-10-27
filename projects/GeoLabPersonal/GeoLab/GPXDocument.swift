import SwiftUI
import UniformTypeIdentifiers

struct GPXDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "gpx") ?? .xml, .xml] }
    static var writableContentTypes: [UTType] { [UTType(filenameExtension: "gpx") ?? .xml] }
    var xml: String = ""

    init(xml: String) { self.xml = xml }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let xml = String(data: data, encoding: .utf8) else { throw CocoaError(.fileReadCorruptFile) }
        self.xml = xml
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(xml.utf8))
    }
}
