//
//  DataSyncView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/11/25.
//

import SwiftUI

struct DataSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showFileImporter = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export / Import Exercise Data")
                .font(.headline)
                .padding(.top)

            ShareLink(
                items: [DataSyncService(modelContext: modelContext).prepareFileForExport()].compactMap({ $0 })
            ) {
                Label("Export Data", systemImage: "square.and.arrow.up.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Button {
                showFileImporter.toggle()
            } label: {
                Label("Import Data", systemImage: "square.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                switch result {
                case .success(let url):
                            // Gain permission to access the file
                        guard url.startAccessingSecurityScopedResource() else {
                            fatalError("Failed to start accessing security-scoped resource.")
                        }
                    do {
                        let csvString = try String(contentsOf: url, encoding: .utf8)
                        let dataSyncService = DataSyncService(modelContext: modelContext)
                        dataSyncService.importData(csvString: csvString)
                    } catch {
                        fatalError("Failed to read or process file for import: \(error)")
                    }
                case .failure(let error):
                        fatalError("File import failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    DataSyncView()
}
