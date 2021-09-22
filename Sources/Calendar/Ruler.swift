//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2021/09/22.
//

import SwiftUI

struct Ruler: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    var offset: CGPoint = .zero

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                TimelineRuler { time in
                    Text(time)
                        .font(.footnote)
                }
                    .frame(height: proxy.size.height)
                    .offset(y: offset.y)
            }
        }

#if os(iOS)
        .frame(width: horizontalSizeClass == .compact ? 64 : 80)
#else
        .frame(width: 80)
#endif
    }
}
