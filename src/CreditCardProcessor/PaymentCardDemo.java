package CreditCardProcessor;
public class PaymentCardDemo {
	
	public static void main(String [] args) throws CardReadException, PaymentGatewayException {
		//PaymentCard card = new PaymentCard("%A6394631054178689^STURGEON/ZACHARY ^62127011000042500425?;6394631054178689=621270110000425?");
		PaymentCard card = new PaymentCard(";6273660683962088?+E?");
		//PaymentCard card = new PaymentCard(";6273660633962088?"); // nonexistent
		//PaymentCard card2 = new PaymentCard(";E?+E?");
		//System.out.println(card.primaryAccountNumber);
		
		PaymentGateway gateway = new PaymentGateway("paymentproxy.unread.db");
		//gateway.addCardIssuer("NOVACard", 16, "62", false, false);
		//gateway.addCardholder("NOVACard", card.primaryAccountNumber, "Zachary Sturgeon", 100.0);
		//gateway.addMerchant("NOVA Cafe");
		//System.exit(0);
		
		CardIssuer issuer = gateway.findIssuer(card.iin);
		if (issuer == null) {
			System.out.println("Card not accepted here, no card issuer found.");
		} else {
			System.out.println(issuer.name);
			CardHolder person = gateway.getCardHolder(issuer, card.primaryAccountNumber);
			if (person == null) {
				System.out.println("Cardholder was not found");
			} else {
				
				System.out.println(person.name);
				
				boolean success = gateway.doTransaction(person, "NOVA Cafe", 1);
				if (!success) {
					System.out.println("Insufficient funds");
				}
			}
		}
		gateway.close();
		
	}

}
