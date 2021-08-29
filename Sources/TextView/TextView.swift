import SwiftUI

struct RoundedTextView: View {
    @State private var text: String = ""

    var body: some View {
        TextView($text)
            .font(.system(.headline))
            .placeholder("Enter some text")
            .multilineTextAlignment(.leading)
            .enableScrolling(true)
            .padding(.leading, 5)
            .frame(maxHeight: 100)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color(.placeholderText))
            )
            .padding()
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTextView()
    }
}

struct TextView: View {

    @Environment(\.layoutDirection) private var layoutDirection

    @Binding private var text: String
    
    @State private var calculatedHeight: CGFloat = 44
    @State private var isEmpty: Bool = false

    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?

    private var placeholderView: AnyView?
    private var foregroundColor: UIColor = .label
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var multilineTextAlignment: TextAlignment = .leading
    private var font: UIFont = .preferredFont(forTextStyle: .callout)
    private var returnKeyType: UIReturnKeyType?
    private var clearsOnInsertion: Bool = false
    private var autocorrection: UITextAutocorrectionType = .default
    private var truncationMode: NSLineBreakMode = .byTruncatingTail
    private var isSecure: Bool = false
    private var isEditable: Bool = true
    private var isSelectable: Bool = true
    private var isScrollingEnabled: Bool = false
    private var enablesReturnKeyAutomatically: Bool?
    private var autoDetectionTypes: UIDataDetectorTypes = []

    private var internalText: Binding<String> {
        Binding<String>(get: { self.text }) {
            self.text = $0
            self.isEmpty = $0.isEmpty
        }
    }

    init(_ text: Binding<String>,
         shouldEditInRange: ((Range<String.Index>, String) -> Bool)? = nil,
         onEditingChanged: (() -> Void)? = nil,
         onCommit: (() -> Void)? = nil) {

        _text = text
        _isEmpty = State(initialValue: text.wrappedValue.isEmpty)

        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        SwiftUITextView(
            internalText,
            foregroundColor: foregroundColor,
            font: font,
            multilineTextAlignment: multilineTextAlignment,
            autocapitalization: autocapitalization,
            returnKeyType: returnKeyType,
            clearsOnInsertion: clearsOnInsertion,
            autocorrection: autocorrection,
            truncationMode: truncationMode,
            isSecure: isSecure,
            isEditable: isEditable,
            isSelectable: isSelectable,
            isScrollingEnabled: isScrollingEnabled,
            enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
            autoDetectionTypes: autoDetectionTypes,
            calculatedHeight: $calculatedHeight,
            shouldEditInRange: shouldEditInRange,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
        .frame(
            minHeight: isScrollingEnabled ? 0 : calculatedHeight,
            maxHeight: isScrollingEnabled ? .infinity : calculatedHeight
        )
        .background(
            placeholderView?
                .foregroundColor(Color(.placeholderText))
                .multilineTextAlignment(multilineTextAlignment)
                .font(Font(font))
                .padding(.horizontal, isScrollingEnabled ? 5 : 0)
                .padding(.vertical, isScrollingEnabled ? 8 : 0)
                .opacity(isEmpty ? 1 : 0),
            alignment: .topLeading
        )
    }

}

extension TextView {

    func placeholder(_ placeholder: String) -> TextView {
        self.placeholder(placeholder) { $0 }
    }

    func placeholder<V: View>(_ placeholder: String, _ configure: (Text) -> V) -> TextView {
        var view = self
        let text = Text(placeholder)
        view.placeholderView = AnyView(configure(text))
        return view
    }

    func placeholder<V: View>(_ placeholder: V) -> TextView {
        var view = self
        view.placeholderView = AnyView(placeholder)
        return view
    }

    func autoDetectDataTypes(_ types: UIDataDetectorTypes) -> TextView {
        var view = self
        view.autoDetectionTypes = types
        return view
    }

    func foregroundColor(_ color: UIColor) -> TextView {
        var view = self
        view.foregroundColor = color
        return view
    }

    func autocapitalization(_ style: UITextAutocapitalizationType) -> TextView {
        var view = self
        view.autocapitalization = style
        return view
    }

    func multilineTextAlignment(_ alignment: TextAlignment) -> TextView {
        var view = self
        view.multilineTextAlignment = alignment
        return view
    }

    func font(_ font: UIFont) -> TextView {
        var view = self
        view.font = font
        return view
    }

    func fontWeight(_ weight: UIFont.Weight) -> TextView {
        font(font.weight(weight))
    }

    func clearOnInsertion(_ value: Bool) -> TextView {
        var view = self
        view.clearsOnInsertion = value
        return view
    }

    func disableAutocorrection(_ disable: Bool?) -> TextView {
        var view = self
        if let disable = disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }

    func isEditable(_ isEditable: Bool) -> TextView {
        var view = self
        view.isEditable = isEditable
        return view
    }

    func isSelectable(_ isSelectable: Bool) -> TextView {
        var view = self
        view.isSelectable = isSelectable
        return view
    }

    func enableScrolling(_ isScrollingEnabled: Bool) -> TextView {
        var view = self
        view.isScrollingEnabled = isScrollingEnabled
        return view
    }

    func returnKey(_ style: UIReturnKeyType?) -> TextView {
        var view = self
        view.returnKeyType = style
        return view
    }

    func automaticallyEnablesReturn(_ value: Bool?) -> TextView {
        var view = self
        view.enablesReturnKeyAutomatically = value
        return view
    }

    func truncationMode(_ mode: Text.TruncationMode) -> TextView {
        var view = self
        switch mode {
        case .head: view.truncationMode = .byTruncatingHead
        case .tail: view.truncationMode = .byTruncatingTail
        case .middle: view.truncationMode = .byTruncatingMiddle
        @unknown default:
            fatalError("Unknown text truncation mode")
        }
        return view
    }

}

private struct SwiftUITextView: UIViewRepresentable {

    @Binding private var text: String
    @Binding private var calculatedHeight: CGFloat

    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?

    private let foregroundColor: UIColor
    private let autocapitalization: UITextAutocapitalizationType
    private var multilineTextAlignment: TextAlignment
    private let font: UIFont
    private let returnKeyType: UIReturnKeyType?
    private let clearsOnInsertion: Bool
    private let autocorrection: UITextAutocorrectionType
    private let truncationMode: NSLineBreakMode
    private let isSecure: Bool
    private let isEditable: Bool
    private let isSelectable: Bool
    private let isScrollingEnabled: Bool
    private let enablesReturnKeyAutomatically: Bool?
    private var autoDetectionTypes: UIDataDetectorTypes = []

    init(_ text: Binding<String>,
         foregroundColor: UIColor,
         font: UIFont,
         multilineTextAlignment: TextAlignment,
         autocapitalization: UITextAutocapitalizationType,
         returnKeyType: UIReturnKeyType?,
         clearsOnInsertion: Bool,
         autocorrection: UITextAutocorrectionType,
         truncationMode: NSLineBreakMode,
         isSecure: Bool,
         isEditable: Bool,
         isSelectable: Bool,
         isScrollingEnabled: Bool,
         enablesReturnKeyAutomatically: Bool?,
         autoDetectionTypes: UIDataDetectorTypes,
         calculatedHeight: Binding<CGFloat>,
         shouldEditInRange: ((Range<String.Index>, String) -> Bool)?,
         onEditingChanged: (() -> Void)?,
         onCommit: (() -> Void)?) {
        _text = text
        _calculatedHeight = calculatedHeight

        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged
        self.multilineTextAlignment = multilineTextAlignment
        self.foregroundColor = foregroundColor
        self.font = font
        self.autocapitalization = autocapitalization
        self.returnKeyType = returnKeyType
        self.clearsOnInsertion = clearsOnInsertion
        self.autocorrection = autocorrection
        self.truncationMode = truncationMode
        self.isSecure = isSecure
        self.isEditable = isEditable
        self.isSelectable = isSelectable
        self.isScrollingEnabled = isScrollingEnabled
        self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        self.autoDetectionTypes = autoDetectionTypes

        makeCoordinator()
    }

    func makeUIView(context: Context) -> UIKitTextView {
        let view = UIKitTextView()
        view.delegate = context.coordinator
        view.backgroundColor = UIColor.clear
        view.adjustsFontForContentSizeCategory = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ view: UIKitTextView, context: Context) {
        view.text = text
        view.font = font
        view.textColor = foregroundColor
        view.autocapitalizationType = autocapitalization
        view.autocorrectionType = autocorrection
        view.isEditable = isEditable
        view.isSelectable = isSelectable
        view.isScrollEnabled = isScrollingEnabled
        view.dataDetectorTypes = autoDetectionTypes

        switch multilineTextAlignment {
        case .leading:
            view.textAlignment = view.traitCollection.layoutDirection ~= .leftToRight ? .left : .right
        case .trailing:
            view.textAlignment = view.traitCollection.layoutDirection ~= .leftToRight ? .right : .left
        case .center:
            view.textAlignment = .center
        }

        if let value = enablesReturnKeyAutomatically {
            view.enablesReturnKeyAutomatically = value
        } else {
            view.enablesReturnKeyAutomatically = onCommit == nil ? false : true
        }

        if let returnKeyType = returnKeyType {
            view.returnKeyType = returnKeyType
        } else {
            view.returnKeyType = onCommit == nil ? .default : .done
        }

        if !isScrollingEnabled {
            view.textContainer.lineFragmentPadding = 0
            view.textContainerInset = .zero
        }

        SwiftUITextView.recalculateHeight(view: view, result: $calculatedHeight)
    }

    @discardableResult func makeCoordinator() -> Coordinator {
        return Coordinator(
            text: $text,
            calculatedHeight: $calculatedHeight,
            shouldEditInRange: shouldEditInRange,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))

        guard result.wrappedValue != newSize.height else { return }
        DispatchQueue.main.async { // call in next render cycle.
            result.wrappedValue = newSize.height
        }
    }

}

private extension SwiftUITextView {

    final class Coordinator: NSObject, UITextViewDelegate {

        private var originalText: String = ""
        private var text: Binding<String>
        private var calculatedHeight: Binding<CGFloat>

        var onCommit: (() -> Void)?
        var onEditingChanged: (() -> Void)?
        var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?

        init(text: Binding<String>,
             calculatedHeight: Binding<CGFloat>,
             shouldEditInRange: ((Range<String.Index>, String) -> Bool)?,
             onEditingChanged: (() -> Void)?,
             onCommit: (() -> Void)?) {
            self.text = text
            self.calculatedHeight = calculatedHeight
            self.shouldEditInRange = shouldEditInRange
            self.onEditingChanged = onEditingChanged
            self.onCommit = onCommit
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            originalText = text.wrappedValue
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            SwiftUITextView.recalculateHeight(view: textView, result: calculatedHeight)
            onEditingChanged?()
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if onCommit != nil, text == "\n" {
                onCommit?()
                originalText = textView.text
                textView.resignFirstResponder()
                return false
            }

            return true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            // this check is to ensure we always commit text when we're not using a closure
            if onCommit != nil {
                text.wrappedValue = originalText
            }
        }

    }

}

private final class UIKitTextView: UITextView {

    override var keyCommands: [UIKeyCommand]? {
        return (super.keyCommands ?? []) + [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape(_:)))
        ]
    }

    @objc private func escape(_ sender: Any) {
        resignFirstResponder()
    }

}
