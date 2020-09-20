//
//  ImageTransition.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/9/18.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
    import UIKit

    /// Transition effect which will be used when an image downloaded and set by `UIImageView`
    /// extension API in Kingfisher. You can assign an enum value with transition duration as
    /// an item in `KingfisherOptionsInfo` to enable the animation transition.
    ///
    /// Apple's UIViewAnimationOptions is used under the hood.
    /// For custom transition, you should specified your own transition options, animations and
    /// completion handler as well.
    ///
    /// - none: No animation transition.
    /// - fade: Fade in the loaded image in a given duration.
    /// - flipFromLeft: Flip from left transition.
    /// - flipFromRight: Flip from right transition.
    /// - flipFromTop: Flip from top transition.
    /// - flipFromBottom: Flip from bottom transition.
    /// - custom: Custom transition.
    public enum ImageTransition {
        /// No animation transition.
        case none
        /// Fade in the loaded image in a given duration.
        case fade(TimeInterval)
        /// Flip from left transition.
        case flipFromLeft(TimeInterval)
        /// Flip from right transition.
        case flipFromRight(TimeInterval)
        /// Flip from top transition.
        case flipFromTop(TimeInterval)
        /// Flip from bottom transition.
        case flipFromBottom(TimeInterval)
        /// Custom transition defined by a general animation block.
        ///    - duration: The time duration of this custom transition.
        ///    - options: `UIView.AnimationOptions` should be used in the transition.
        ///    - animations: The animation block will be applied when setting image.
        ///    - completion: A block called when the transition animation finishes.
        case custom(duration: TimeInterval,
                    options: UIView.AnimationOptions,
                    animations: ((UIImageView, UIImage) -> Void)?,
                    completion: ((Bool) -> Void)?)

        var duration: TimeInterval {
            switch self {
            case .none: return 0
            case let .fade(duration): return duration

            case let .flipFromLeft(duration): return duration
            case let .flipFromRight(duration): return duration
            case let .flipFromTop(duration): return duration
            case let .flipFromBottom(duration): return duration

            case let .custom(duration, _, _, _): return duration
            }
        }

        var animationOptions: UIView.AnimationOptions {
            switch self {
            case .none: return []
            case .fade: return .transitionCrossDissolve

            case .flipFromLeft: return .transitionFlipFromLeft
            case .flipFromRight: return .transitionFlipFromRight
            case .flipFromTop: return .transitionFlipFromTop
            case .flipFromBottom: return .transitionFlipFromBottom

            case let .custom(_, options, _, _): return options
            }
        }

        var animations: ((UIImageView, UIImage) -> Void)? {
            switch self {
            case let .custom(_, _, animations, _): return animations
            default: return { $0.image = $1 }
            }
        }

        var completion: ((Bool) -> Void)? {
            switch self {
            case let .custom(_, _, _, completion): return completion
            default: return nil
            }
        }
    }
#else
    // Just a placeholder for compiling on macOS.
    public enum ImageTransition {
        case none
    }
#endif
