//
//  BackgroundView.swift
//  demo
//
//  Created by Johan Halin on 15.9.2020.
//  Copyright © 2020 Dekadence. All rights reserved.
//

import Foundation
import UIKit

class BackgroundView: UIView {
    let viewCount = 64
    let views: [UIView]

    override init(frame: CGRect) {
        var views = [UIView]()

        for _ in 0...self.viewCount {
            let view = UIView()
            view.backgroundColor = .white
            views.append(view)
        }

        self.views = views

        super.init(frame: frame)

        for view in views {
            addSubview(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animate(duration: TimeInterval) {
        let width = self.bounds.size.width / CGFloat(self.viewCount)

        for (i, view) in self.views.enumerated() {
            view.frame = CGRect(
                x: width * CGFloat(i),
                y: 0,
                width: width,
                height: self.bounds.size.height
            )
        }

        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            for view in self.views {
                view.frame.origin.x += CGFloat.random(in: -100...100)
            }
        }, completion: nil)
    }
}
