//
//  progressBarView.swift
//  twentyOneDay
//
//  Created by Burak on 18.08.2023.
//

import SwiftUI

struct progressBarView: View {
    var width:CGFloat = 200
    var height:CGFloat = 20
    var percent:CGFloat = 40
    var color1:Color = Color("N-Color03")
    var color2:Color = Color("N-Color01")
    
    var body: some View {
        
        ZStack(alignment: .leading){
            let multiplier = width / 100
            RoundedRectangle(cornerRadius: height,style: .continuous).frame(width:width,height: height).foregroundColor(Color.black.opacity(0.06))
            
            RoundedRectangle(cornerRadius: height,style: .continuous).frame(width: percent * multiplier,height: height).background(
                LinearGradient(gradient: Gradient(colors: [color1,color2]), startPoint: .leading, endPoint: .trailing).clipShape(RoundedRectangle(cornerRadius: height,style: .continuous))
            ).foregroundColor(.clear)
            
            
        }
    }
}

struct progressBarView_Previews: PreviewProvider {
    static var previews: some View {
        progressBarView()
    }
}
