//
//  ActionLabelView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 19.05.23.
//

import UIKit

protocol ActionLabelViewDelegate: AnyObject{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
}
class ActionLabelView: UIView {

    weak var delegate: ActionLabelViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isHidden = true
        addSubview(button)
        addSubview(label)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 0, y: (height - 50) / 2, width: width, height: 20)
        button.frame = CGRect(x: 0, y: (height + 10) / 2, width: width, height: 20)
    }
    
    @objc private func didTapButton(){
        delegate?.actionLabelViewDidTapButton(self)
    }
    
    func configure(with viewModel: ActionLabelViewModel){
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
