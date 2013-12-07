import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import com.almworks.sqlite4java.*;


public class PaymentGateway {
	
	public SQLiteConnection db = null;
	
	public PaymentGateway(String databaseFile) {
		
		db = new SQLiteConnection(new File(databaseFile));
		try {
			db.open(true);
			this.CreateTables();
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
	private void CreateTables() throws SQLiteException {
		
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
					+ "	issuer_id INTEGER, account_number TEXT NOT NULL, ammount REAL NOT NULL,"
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
	public void AddCardIssuer(String issuerName, int PANLength, 
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
			this.AddCardIssuerAccountTable(issuerName, PANLength);
			
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
	private void AddCardIssuerAccountTable(String issuerName, int PANLength) 
			throws PaymentGatewayException {
		
		// FIXME: Check to see if issuer already exists.
		
		SQLiteStatement st;
		
		try {
			// WARNING: THIS HAS SQL INJECTION.  NOT FOR PRODUCTION USE.  YOU'VE BEEN WARNED
			st = db.prepare("CREATE TABLE `debit_" + issuerName + "` (id INTEGER PRIMARY KEY,"
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
	public void AddMerchant(String name) {
		
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
	 */
	public CardIssuer FindIssuer(String iin) {
		
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
			e.printStackTrace();
		}
		
		return issuer;
		
	}

}


