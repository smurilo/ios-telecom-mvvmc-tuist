import UIKit
import TelecomCore
import TelecomFeatures

final class OfferViewController: UIViewController {
    private let viewModel: OfferViewModel
    private var token: ObservationToken?
    private let price = UILabel()
    private let error = UILabel()
    private let buy = UIButton(configuration: .filled())

    init(viewModel: OfferViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in self?.viewModel.cancel() })
        price.font = .preferredFont(forTextStyle: .largeTitle)
        error.textColor = .systemRed
        error.numberOfLines = 0
        buy.configuration?.title = "Contratar"
        buy.addAction(UIAction { [weak self] _ in Task { await self?.viewModel.confirm() } }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [price, error, buy])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        token = viewModel.state.bind { [weak self] state in
            self?.title = state.title
            self?.price.text = state.priceText
            self?.error.text = state.error
            self?.buy.configuration?.showsActivityIndicator = state.isPurchasing
            self?.buy.isEnabled = !state.isPurchasing
        }
    }
}

final class InvoicesViewController: UITableViewController {
    private let service: TelecomServicing
    private var invoices: [Invoice] = []

    init(service: TelecomServicing) {
        self.service = service
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Faturas"
        Task {
            invoices = (try? await service.invoices()) ?? []
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { invoices.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let invoice = invoices[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = "\(invoice.month) • \(Formatters.money(invoice.amount))"
        content.secondaryText = invoice.status == .paid ? "Paga" : "Toque para copiar o código de barras"
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let invoice = invoices[indexPath.row]
        guard invoice.status != .paid else { return }
        UIPasteboard.general.string = invoice.barcode
        let alert = UIAlertController(title: "Código copiado", message: invoice.barcode, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
