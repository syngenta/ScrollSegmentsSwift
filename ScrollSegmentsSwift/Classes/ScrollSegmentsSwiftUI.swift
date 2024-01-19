//
//  ScrollSegmentsSwiftUI.swift
//
//
//  Created by Dmytro Romanov on 18.01.2024.
//

import SwiftUI

public struct ScrollSegmentsSwiftUI: UIViewRepresentable {
    var titles: [String]
    var style: ScrollSegmentStyle
    var onSegmentSelected: (Int) -> Void

    public func makeUIView(context: Context) -> ScrollSegmentsSwift {
        let segments = ScrollSegmentsSwift(titles: titles, style: style)
        segments.delegate = context.coordinator
        return segments
    }

    public func updateUIView(_ uiView: ScrollSegmentsSwift, context: Context) {
        uiView.titles = titles
        uiView.style = style
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, ScrollSegmentDelegate {
        var parent: ScrollSegmentsSwiftUI

        init(_ parent: ScrollSegmentsSwiftUI) {
            self.parent = parent
        }

        public func segmentSelected(index: Int) {
            parent.onSegmentSelected(index)
        }
    }
}

struct ScrollSegmentsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ScrollSegmentsSwiftUI(titles: ["First",
                                           "Second",
                                           "Third",
                                           "@",
                                           "Really long title",
                                           "Last"],
                                  style: ScrollSegmentStyle()) {
                print("Selected - \($0)")
            }.frame(height: 50)
            Spacer()
        }
    }
}
