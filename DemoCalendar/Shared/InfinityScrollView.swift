//
//  InfinityScrollView.swift
//  InfinityScrollView
//
//  Created by nori on 2021/09/09.
//

import SwiftUI

class Model: ObservableObject {

    @Published var selection: Int?

    var scrollViewProxy: ScrollViewProxy?

}

struct InfinityScrollView: View {

    @State var height: CGFloat = 0

    @StateObject var model: Model = Model()

    @Namespace var namespace

    func size(_ size: CGSize) -> CGSize {
        if model.selection != nil {
            return size
        }
        return CGSize(width: 300, height: 300)
    }

    var columns: [GridItem] {
        if model.selection != nil {
            return [
                GridItem(.flexible())
            ]
        }
        return [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }

    func grid(id: Int, isSource: Bool) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            ForEach(0..<36) { index in
                Rectangle()
                    .fill(Color.green)
                    .overlay {
                        Text("\(index)")
                            .font(.system(size: 22, weight: .heavy))
                    }
                    .frame(width: 30, height: 30, alignment: .center)
                    .matchedGeometryEffect(id: "\(id)-\(index)", in: namespace, isSource: isSource)
            }
        }
    }

    var body: some View {
//        GeometryReader { geometryProxy in
//            ZStack {
//
//                if let selection = model.selection {
//                    ScrollViewReader { proxy in
//                        ScrollView {
//                            LazyVGrid(columns: columns) {
//                                ForEach(0..<100) { index in
//                                    grid(id: index, isSource: model.selection != nil)
//                                        .frame(width: size(geometryProxy.size).width, height: size(geometryProxy.size).height, alignment: .center)
//                                        .onTapGesture {
//                                            withAnimation {
//                                                if model.selection != nil {
//                                                    model.selection = nil
//                                                } else {
//                                                    model.selection = index
//                                                }
//                                            }
//                                        }
//                                        .id(index)
//                                        .matchedGeometryEffect(id: index, in: namespace, isSource: model.selection != nil)
//                                        .onReceive(model.$selection) { newValue in
//                                            if let selection = newValue {
////                                                proxy.scrollTo(selection)
//                                            }
//                                        }
//                                }
//                            }
//                        }
//                        .onAppear {
////                            model.scrollViewProxy = proxy
//                            proxy.scrollTo(selection)
//                        }
//                    }
//                } else {
//                    ScrollViewReader { proxy in
//                        ScrollView {
//                            LazyVGrid(columns: columns) {
//                                ForEach(0..<100) { index in
//                                    grid(id: index, isSource: model.selection == nil)
//                                        .frame(width: size(geometryProxy.size).width, height: size(geometryProxy.size).height, alignment: .center)
//                                        .onTapGesture {
//
//                                            withAnimation {
//                                                if model.selection != nil {
//                                                    model.selection = nil
//                                                } else {
//                                                    model.selection = index
//                                                }
//                                            }
//                                        }
//                                        .matchedGeometryEffect(id: index, in: namespace, isSource: model.selection == nil)
////                                        .id(index)
////                                        .matchedGeometryEffect(id: index, in: namespace, isSource: model.selection == nil)
////                                        .onReceive(model.$selection) { newValue in
////                                            if let selection = newValue {
////                                                proxy.scrollTo(selection)
////                                            }
////                                        }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }



//        if model.selection != nil {
//            GeometryReader { geometryProxy in
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        LazyVGrid(columns: columns) {
//                            ForEach(0..<100) { index in
//                                Rectangle()
//                                    .fill(Color.green)
//                                    .overlay {
//                                        Text("\(index)")
//                                            .font(.system(size: 22, weight: .heavy))
//                                    }
//                                    .frame(width: size(geometryProxy.size).width, height: size(geometryProxy.size).height, alignment: .center)
//                                    .onTapGesture {
//                                        withAnimation {
//                                            self.model.selection = nil
//                                        }
//                                    }
//
//                                    .id(index)
////                                    .matchedGeometryEffect(id: index, in: namespace)
//                                    .onReceive(model.$selection) { newValue in
//                                        if let selection = newValue {
//                                            proxy.scrollTo(selection)
//                                        }
//                                    }
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            GeometryReader { geometryProxy in
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        LazyVGrid(columns: columns) {
//                            ForEach(0..<100) { index in
//                                Rectangle()
//                                    .fill(Color.green)
//                                    .overlay {
//                                        Text("\(index)")
//                                            .font(.system(size: 22, weight: .heavy))
//                                    }
//                                    .frame(width: size(geometryProxy.size).width, height: size(geometryProxy.size).height, alignment: .center)
//                                    .onTapGesture {
//                                        withAnimation {
//                                            model.selection = index
//                                        }
//                                    }
//                                    .id(index)
//                                    .matchedGeometryEffect(id: index, in: namespace)
//                            }
//                        }
//                    }
//                }
//            }
//
//        }




//        GeometryReader { proxy in
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//
//                    LazyVGrid(columns: [GridItem(.fixed(proxy.size.width), spacing: 0)], spacing: 0) {
//                        ForEach(content(proxy.size)) { index in
//                            ZStack {
//                                Text("\(index)")
//                                    .font(.system(size: 30, weight: .heavy))
//                            }
//                            .frame(height: proxy.size.height)
//                        }
//                    }
////                    .offset(offset)
////                    .position(position)
//                    .background(GeometryReader { innerProxy in
//                        Rectangle()
//                            .fill(Color.clear)
//                        .onChange(of: innerProxy.frame(in: .named("scroll"))) { newValue in
//                            let frame = innerProxy.frame(in: .named("scroll"))
//
//                            DispatchQueue.main.async {
//                                self.offset = CGSize(width: frame.origin.x, height: 0)
//                                self.position = CGPoint(x: frame.width / 2, y: 0)
//                            }
//
//                            print(innerProxy.frame(in: .global))
//                        }
//                    })
//
//                }
//
//                .coordinateSpace(name: "scroll")
//            }
//        }

        HStack {
            ForEach(0..<10000000) { index in
                Text("\(index)")
            }
        }

    }

    @State var offset: CGSize = .zero

    @State var position: CGPoint = .zero

    func content(_ size: CGSize) -> Range<Int> {
        return (0..<3)
    }

}

struct InfinityScrollView_Previews: PreviewProvider {
    static var previews: some View {
        InfinityScrollView()
    }
}
