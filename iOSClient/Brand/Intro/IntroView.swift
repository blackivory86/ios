//
//  IntroView.swift
//  Nextcloud
//
//  Created by Philippe Weidmann on 15.11.19.
//  Copyright © 2019 Philippe Weidmann. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//


import UIKit

class IntroView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonHost: UIButton!
    @IBOutlet weak var introCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @objc var delegate: CCSplit?
    private let titles = [NSLocalizedString("_intro_1_title_", comment: ""), NSLocalizedString("_intro_2_title_", comment: ""), NSLocalizedString("_intro_3_title_", comment: ""), NSLocalizedString("_intro_4_title_", comment: "")]
    private let images = [UIImage(named: "intro1"), UIImage(named: "intro2"), UIImage(named: "intro3"), UIImage(named: "intro4")]
    private var timerAutoScroll: Timer?

    @objc func autoScroll() {
        if(pageControl.currentPage + 1 >= titles.count) {
            pageControl.currentPage = 0
        }
        else {
            pageControl.currentPage += 1
        }
        introCollectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }

    override func layoutSubviews() {
        pageControl.currentPage = 0
        introCollectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return CGPoint.zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "introCell", for: indexPath) as! IntroCollectionViewCell
        cell.backgroundColor = NCBrandColor.sharedInstance.customer

        cell.titleLabel.textColor = NCBrandColor.sharedInstance.customerText
        cell.titleLabel.text = titles[indexPath.row]
        cell.imageView.image = images[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        timerAutoScroll = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(IntroView.autoScroll)), userInfo: nil, repeats: true)
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timerAutoScroll?.invalidate()
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        timerAutoScroll?.invalidate()
    }

    @objc class func instanceFromNib() -> IntroView {
        let view = UINib(nibName: "IntroView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! IntroView

        view.buttonLogin.layer.cornerRadius = 20
        view.buttonLogin.setTitleColor(.black, for: .normal)
        view.buttonLogin.backgroundColor = NCBrandColor.sharedInstance.customerText
        view.buttonLogin.setTitle(NSLocalizedString("_log_in_", comment: ""), for: .normal)

        view.buttonSignUp.layer.cornerRadius = 20
        view.buttonSignUp.setTitleColor(.white, for: .normal)
        view.buttonSignUp.backgroundColor = UIColor(red: 25.0 / 255.0, green: 89.0 / 255.0, blue: 141.0 / 255.0, alpha: 1)
        view.buttonSignUp.setTitle(NSLocalizedString("_sign_up_", comment: ""), for: .normal)

        view.buttonHost.layer.cornerRadius = 20
        view.buttonHost.setTitle(NSLocalizedString("_host_your_own_server", comment: ""), for: .normal)
        view.buttonHost.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.7), for: .normal)

        view.introCollectionView.register(UINib(nibName: "IntroCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "introCell")
        view.introCollectionView.dataSource = view
        view.introCollectionView.delegate = view
        view.introCollectionView.backgroundColor = NCBrandColor.sharedInstance.customer
        view.pageControl.numberOfPages = view.titles.count
        view.backgroundView.backgroundColor = NCBrandColor.sharedInstance.customer
        view.timerAutoScroll = Timer.scheduledTimer(timeInterval: 5, target: view, selector: (#selector(IntroView.autoScroll)), userInfo: nil, repeats: true)

        return view
    }
    
    @IBAction func login(_ sender: Any) {
        delegate?.introFinishSelector(Int(k_intro_login))
        UIView.animate(withDuration: 1.7) {
            self.alpha = 0
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        delegate?.introFinishSelector(Int(k_intro_signup))
        UIView.animate(withDuration: 1.7) {
            self.alpha = 0
        }
    }
    
    @IBAction func host(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let browserWebVC = UIStoryboard(name: "NCBrowserWeb", bundle: nil).instantiateInitialViewController() as? NCBrowserWeb
        
        browserWebVC?.urlBase = NCBrandOptions.sharedInstance.linkLoginHost
        
        if let browserWebVC = browserWebVC {
            appDelegate?.window.rootViewController?.present(browserWebVC, animated: true)
        }
    }

}
