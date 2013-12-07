
public class PaymentGatewayException extends Exception {

	private static final long serialVersionUID = -6364406353658114337L;
	Exception base = null;

	public PaymentGatewayException(String message) {
		super(message);
	}
	
	public PaymentGatewayException(String message, Exception baseException) {
		super(message);
		base = baseException;
	}

}
