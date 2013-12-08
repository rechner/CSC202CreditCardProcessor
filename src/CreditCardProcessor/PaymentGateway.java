package CreditCardProcessor;
import java.io.File;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import com.almworks.sqlite4java.*;


public class PaymentGateway {
	
	public SQLiteConnection db = null;
	
	public PaymentGateway(String databaseFile) {
		
		db = new SQLiteConnection(new File(databaseFile));
		try {
			db.open(true);
			this.createTables();
		} catch (SQLiteException e) {
			e.printStackTrace();
		}
	}
	
	public void close() {
		db.dispose();
	}
	
	/**
	 * Initialises an empty database.
	 * @throws SQLiteException
	 */
	private void createTables() throws SQLiteException {
		
		SQLiteStatement st;
		try {
			st = db.prepare("SELECT name FROM merchant;");
			st.stepThrough();
			st.dispose();
		
		} catch (SQLiteException e) {
			// the table we queried probably doesn't exist. Create tables:
			
			// gateway table
			st = db.prepare("CREATE TABLE IF NOT EXISTS `gateway` (id INTEGER PRIMARY KEY,"
					+ "	issuer TEXT NOT NULL, length INT DEFAULT 16 NOT NULL,"
					+ "	iin_number TEXT NOT NULL, luhn_validation BOOLEAN "
					+ "DEFAULT TRUE NOT NULL, enforce_expiry BOOLEAN DEFAULT "
					+ "FALSE NOT NULL);");
			st.stepThrough();
			st.dispose();
			
			//transactions table
			st = db.prepare("CREATE TABLE IF NOT EXISTS `transactions` (id INTEGER PRIMARY KEY,"
					+ "	issuer_id INTEGER, account_number TEXT NOT NULL, amount REAL NOT NULL,"
					+ "	timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,"
					+ "	settled BOOLEAN DEFAULT NULL, merchant INTEGER,"
					+ "	FOREIGN KEY(merchant) REFERENCES merchant(id));");
			st.stepThrough();
			st.dispose();
			
			//merchant table
			st = db.prepare("CREATE TABLE IF NOT EXISTS `merchants` (id INTEGER PRIMARY KEY,"
					+ " balance REAL NOT NULL DEFAULT 0, name TEXT);");
			st.stepThrough();
			st.dispose();
			
		}
				
	}
	
	/**
	 * Adds a card issuer to the system.
	 * 
	 * @param issuerName String identifying the issuer belonging to this record
	 * @param PANLength integer Length of the personal account number (PAN).  Usually 16 digits.
	 * @param iin_number Two digit string identifying the issuing organisation.  Prefix for PAN.
	 * @param isLuhn Set to true if account numbers should be checked with the Luhn algorithm.
	 * @return
	 * 
	 */
	public void addCardIssuer(String issuerName, int PANLength, 
		String iin_number, boolean isLuhn, boolean enforceExpiry) 
				throws PaymentGatewayException {
		
		// insert issuer row into `gateway`:
		SQLiteStatement st;
		
		try {
			
			st = db.prepare("INSERT INTO gateway(issuer, length, iin_number, luhn_validation,"
					+ " enforce_expiry) VALUES (?, ?, ?, ?, ?);");
			st.bind(1,  issuerName);
			st.bind(2, PANLength);
			st.bind(3, iin_number);
			st.bind(4, (isLuhn ? 1 : 0));  // beautiful ternary expressions
			st.bind(5, (enforceExpiry ? 1: 0)); // (the SQL driver doesn't do booleans) 
			st.stepThrough();
			st.dispose();
			
			// Add the supporting tables:
			this.addCardIssuerAccountTable(issuerName, PANLength);
			
		} catch (SQLiteException e) {
			e.printStackTrace();
			//throw new PaymentGatewayException("Unable to add card issuer to database: " + e.getMessage(), e);		
		}
		
	}
	
	
	/**
	 * Adds the supporting table for a card issuer, to contain all of the issuer 
	 * customer accounts and information.
	 * @param issuerName String issuer name (e.g. "Discover", "Visa").
	 * @param PANLength integer length that personal account numbers should be (usually 16).
	 * @throws PaymentGatewayException 
	 */
	private void addCardIssuerAccountTable(String issuerName, int PANLength) 
			throws PaymentGatewayException {
		
		// FIXME: Check to see if issuer already exists.
		
		SQLiteStatement st;
		
		try {
			// WARNING: THIS HAS SQL INJECTION.  NOT FOR PRODUCTION USE.  YOU'VE BEEN WARNED
			st = db.prepare("CREATE TABLE IF NOT EXISTS `debit_" + issuerName + "` (id INTEGER PRIMARY KEY,"
					+ " account_number TEXT NOT NULL CHECK (LENGTH(account_number) = " + PANLength + "),"
					+ "	balance REAL CHECK (balance >= 0) DEFAULT 0,"
					+ "	name TEXT NOT NULL);");
	
			st.stepThrough();
			st.dispose();		
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Unable to add card issuer to database: " + e.getMessage(), e);
		}
	}
	
	/**
	 * Adds a merchant to the system with a zero balance.
	 * @param name String name of the merchant (e.g. "Acme Corp")
	 */
	public void addMerchant(String name) {
		
		SQLiteStatement st;
		
		try {
			st = db.prepare("INSERT INTO merchants(name) VALUES (?);");
			st.bind(1, name);
			st.stepThrough();
			st.dispose();
			
		} catch (SQLiteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Get information about the issuer from the Issuer Identification Number (IIN).
	 * 
	 * @param iin 2 digit IIN number (as string).
	 * @return CardIssuer object, or null if issuer doesn't exist.
	 * @throws PaymentGatewayException 
	 */
	public CardIssuer findIssuer(String iin) throws PaymentGatewayException {
		
		SQLiteStatement st;
		
		CardIssuer issuer = null;
		int id, length;
		String issuerName, iin_number;
		boolean luhn_validation, enforce_expiry;
		
		try {
			st = db.prepare("SELECT id, issuer, length, iin_number, "
					+ "luhn_validation, enforce_expiry "
					+ "FROM gateway WHERE iin_number = ?;");
			st.bind(1, iin);
			while (st.step()) {
				id = st.columnInt(0);
				issuerName = st.columnString(1);
				length = st.columnInt(2);
				iin_number = st.columnString(3);
				luhn_validation = (st.columnInt(4) == 1 ? true : false);
				enforce_expiry = (st.columnInt(5) == 1 ? true : false);
				
				issuer = new CardIssuer(id, issuerName, length, iin_number, 
						luhn_validation, enforce_expiry);
			}
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException(e.getMessage());
		}
		
		return issuer;
		
	}

	public void addCardholder(String issuerName, String primaryAccountNumber, String name, double balance) { 

		SQLiteStatement st;
		
		try {
			st = db.prepare("INSERT INTO `debit_" + issuerName + "` (account_number, "
					+ "name, balance) VALUES (?, ?, ?);");
			st.bind(1,  primaryAccountNumber);
			st.bind(2, name);
			st.bind(3, balance);
			st.stepThrough();
			st.dispose();
		} catch (SQLiteException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Lookup function for an account.  Returns null if doesn't exist.
	 * @param issuer
	 * @param primaryAccountNumber
	 * @return
	 * @throws PaymentGatewayException 
	 */
	public CardHolder getCardHolder(CardIssuer issuer, String primaryAccountNumber) throws PaymentGatewayException {
		
		SQLiteStatement st;
		CardHolder person = new CardHolder();
		
		try {
			st = db.prepare("SELECT id, balance, name FROM `debit_" + issuer.name + "`"
					+ " WHERE account_number = ?");
			st.bind(1, primaryAccountNumber);
			
			while (st.step()) {
				person.id = st.columnInt(0);
				person.balance = st.columnDouble(1);
				person.name = st.columnString(2);
				person.issuer = issuer;
			}
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException(e.getMessage());
		}
				
		if (person.id != -1) 
			return person;
		else 
			return null;
		
	}
			
	
	/**
	 * Records a transaction and moves funds from a card holder account to
	 * a merchant account.
	 * 
	 * @param person CardHolder object from getCardholder()
	 * @param merchantName 
	 * @param amount
	 * @return True for success, false if insufficient funds.
	 */
	public boolean doTransaction(CardHolder person, String merchantName, double amount) 
			throws PaymentGatewayException {

		if (person.balance < amount) {
			return false;
		}
		
		// begin transaction
		try {
			
			db.exec("BEGIN");
			debitCardHolderAccount(person, amount);
			creditMerchantAccount(merchantName, amount);
			recordTransaction(person, amount, merchantName);
			db.exec("COMMIT");

		} catch (SQLiteException e) {
			try {
				db.exec("ROLLBACK");
				e.printStackTrace();
				throw new PaymentGatewayException("Unable to complete transaction");
			} catch (SQLiteException e1) {
				throw new PaymentGatewayException("Unable to complete transaction");
			}
		}
		
		return true;		
		
	}
	
	private void debitCardHolderAccount(CardHolder person, double amount) 
			throws SQLiteException {
		
		SQLiteStatement st;
		
		st = db.prepare("UPDATE `debit_" + person.issuer.name + "` "
				+ "SET balance = balance - ? WHERE id = ?");
		st.bind(1, amount);
		st.bind(2, person.id);
		st.stepThrough();
		
	}
	
	private void creditMerchantAccount(String merchantName, double amount) 
			throws SQLiteException {
		
		SQLiteStatement st;
		
		st = db.prepare("UPDATE merchants SET balance = balance + ? WHERE name = ?");
		st.bind(1, amount);
		st.bind(2, merchantName);
		st.stepThrough();
		
	}
	
	private void recordTransaction(CardHolder person, double amount, String merchantName)
			throws SQLiteException {
		
		SQLiteStatement st = db.prepare("INSERT INTO transactions(issuer_id, "
				+ "account_number, amount, merchant) VALUES"
				+ "(?, ?, ?, (SELECT id FROM merchants WHERE name = ?));");
		st.bind(1, person.issuer.id);
		st.bind(2, person.id);
		st.bind(3, amount);
		st.bind(4, merchantName);
		st.stepThrough();
		
	}
	
	/**
	 * Returns how much money is in a merchant's account.
	 * 
	 * @param merchantName
	 * @return
	 * @throws PaymentGatewayException
	 */
	public double getMerchantBalance(String merchantName) throws PaymentGatewayException {
		
		double ret = -1;
		
		SQLiteStatement st;
		try {
			st = db.prepare("SELECT balance FROM merchants WHERE name = ?");
			st.bind(1, merchantName);
			while (st.step()) {
				ret = st.columnDouble(0);
			}
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Unable to fetch merchant balance: " + e.getMessage());
		}
		
		return ret;
	}
	
	private int getMerchantID(String merchantName) throws PaymentGatewayException {
		int ret = -1;
		SQLiteStatement st;
		try {
			st = db.prepare("SELECT id FROM merchants WHERE name = ?");
			st.bind(1, merchantName);
			while (st.step()) 
				ret = st.columnInt(0);
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Error while finding merchant ID");
		}
		return ret;
	}
	
	/**
	 * Adds funds to an account.
	 * 
	 * @param person CardHolder instance with account and issuer data.
	 * @param amount amount to deposit.
	 * @throws PaymentGatewayException 
	 */
	public void cardHolderDeposit(CardHolder person, double amount) 
			throws PaymentGatewayException {
		
		SQLiteStatement st;
		
		try {
			st = db.prepare("UPDATE `debit_" + person.issuer.name + "` SET"
					+ " balance = balance + ? WHERE id = ?");
			
			st.bind(1, amount);
			st.bind(2, person.id);
			st.stepThrough();
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Unable to deposit to account: " + e.getMessage());
		}
		
	}	
	
}


