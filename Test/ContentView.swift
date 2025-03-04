//
//  ContentView.swift
//  Test
//
//  Created by Rajveer Mann on 04/03/25.
//

import SwiftUI

struct AsyncImageView: View {
    @State private var imageUrl: String = ""
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var isGrayscale = false
    
    var body: some View {
        VStack {
            TextField("Enter Image URL", text: $imageUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            ZStack {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                        .grayscale(isGrayscale ? 1.0 : 0.0)
                } else if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            
            VStack {
                Button(action: {
                    Task {
                        await loadImage()
                    }
                }) {
                    Text("Load Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Toggle("Grayscale", isOn: $isGrayscale)
                    .padding()
            }
        }
        .padding()
    }
    
    private func loadImage() async {
        isLoading = true
        errorMessage = nil
        uiImage = nil
        
        guard let url = URL(string: imageUrl), !imageUrl.isEmpty else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                uiImage = image
            } else {
                errorMessage = "Failed to load image"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct ContentView: View {
    var body: some View {
        AsyncImageView()
    }
}

#Preview {
        ContentView()
}

