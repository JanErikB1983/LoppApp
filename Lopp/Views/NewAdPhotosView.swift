// Filnavn: NewAdPhotosView.swift
import SwiftUI
import PhotosUI

struct NewAdPhotosView: View {
    @ObservedObject var viewModel: CreateAdViewModel

    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.images, id: \.self) { img in
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal).frame(height: 100)
            }

            PhotosPicker(selection: $viewModel.pickerItems, maxSelectionCount: 5, matching: .images) {
                Text("Velg bilder (max 5)").frame(maxWidth: .infinity).padding()
                    .background(Color.gray.opacity(0.2)).cornerRadius(12)
            }

            Button("Neste ➜") {
                viewModel.path.append(CreateAdViewModel.Step.location)
            }
            // NYTT: Bruker den nye primære stilen
            .buttonStyle(.primary)
            .disabled(viewModel.images.isEmpty)
            
            Spacer()
        }
        .padding()
    }
}
