
import SwiftUI

extension View{
    @ViewBuilder
    func heightChangePreference(completion: @escaping (CGFloat) -> ())-> some View {
        self
            .overlay {
            GeometryReader(content: {geometry in
                Color.clear
                    .preference(key: sizeKey.self, value: geometry.size.height).onPreferenceChange(sizeKey.self, perform:{ value in
                        completion(value)
                    })
                
            })
        }
    }
}
