package ro.racai.reterom.tts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * This class will be used to convert numeric, named or other types of entities into their
 * equivalent "said" form. For instance, number 54 is transformed into "cincizeci și patru".
 * Routines taken from the <a href="https://github.com/racai-ai/ROBINDialog">ROBIN Dialog Manager
 * Java project</a>.
 */
public class SayEntities {
	private static final Pattern NUMBER_RX = Pattern.compile("([0-9]+)");
	private static final Pattern NUMBER_RX2 = Pattern.compile("([0-9]+[.,][0-9]+)");
	private static final Map<Integer, String> NUMBERS = new HashMap<>();
	
	static {
		NUMBERS.put(0, "zero");
		NUMBERS.put(1, "unu");
		NUMBERS.put(2, "doi");
		NUMBERS.put(3, "trei");
		NUMBERS.put(4, "patru");
		NUMBERS.put(5, "cinci");
		NUMBERS.put(6, "șase");
		NUMBERS.put(7, "șapte");
		NUMBERS.put(8, "opt");
		NUMBERS.put(9, "nouă");
		NUMBERS.put(10, "zece");
		NUMBERS.put(11, "unsprezece");
		NUMBERS.put(12, "doisprezece");
		NUMBERS.put(13, "treisprezece");
		NUMBERS.put(14, "paisprezece");
		NUMBERS.put(15, "cincisprezece");
		NUMBERS.put(16, "șaisprezece");
		NUMBERS.put(17, "șaptesprezece");
		NUMBERS.put(18, "optsprezece");
		NUMBERS.put(19, "nouăsprezece");
		NUMBERS.put(20, "douăzeci");
		NUMBERS.put(30, "treizeci");
		NUMBERS.put(40, "patruzeci");
		NUMBERS.put(50, "cincizeci");
		NUMBERS.put(60, "șaizeci");
		NUMBERS.put(70, "șaptezeci");
		NUMBERS.put(80, "optzeci");
		NUMBERS.put(90, "nouăzeci");
	}

	public static String sayNumber(String number) {
		number = number.trim();
		number = number.replaceAll("\\s+", "");
		number = number.replaceAll("[_]+", "");

		if (NUMBER_RX.matcher(number).matches()) {
			int integer = Integer.parseInt(number);

			if (integer >= 0 && integer <= 20) {
				return NUMBERS.get(integer);
			} else {
				List<String> saidNumber = new ArrayList<>();
				boolean tenToNineteen = false;
				int i = 0;

				while (i < number.length()) {
					int tenPower = number.length() - i - 1;
					int units = Integer.parseInt(Character.toString(number.charAt(i)));

					switch (tenPower) {
						case 0:
							if (units > 0 && !tenToNineteen) {
								saidNumber.add(NUMBERS.get(units));
							}
							break;

						case 1:
							if (units >= 2) {
								if (number.endsWith("0")) {
									saidNumber.add(NUMBERS.get(units * 10));
								} else {
									saidNumber.add(NUMBERS.get(units * 10) + " și");
								}
							} else if (units == 1) {
								int lasttwodigits = Integer.parseInt(number.substring(i));

								tenToNineteen = true;
								saidNumber.add(NUMBERS.get(lasttwodigits));
							}
							break;

						case 2:
							if (units == 1) {
								saidNumber.add("o sută");
							} else if (units == 2) {
								saidNumber.add("două sute");
							} else if (units >= 3) {
								saidNumber.add(NUMBERS.get(units) + " sute");
							}
							break;

						case 3:
							if (units == 1) {
								saidNumber.add("o mie");
							} else if (units == 2) {
								saidNumber.add("două mii");
							} else {
								saidNumber.add(NUMBERS.get(units) + " mii");
							}
							break;

						case 4:
							if (units == 1) {
								int nexttwodigits = Integer.parseInt(number.substring(i, i + 2));

								saidNumber.add(NUMBERS.get(nexttwodigits) + " mii");
								i++;
							} else if (units >= 2) {
								int nexttwodigits = Integer.parseInt(number.substring(i, i + 2));

								if (nexttwodigits % 10 == 0) {
									saidNumber.add(NUMBERS.get(nexttwodigits) + " de mii");
								} else {
									saidNumber.add(NUMBERS.get(units * 10) + " și");
									saidNumber.add(
											NUMBERS.get(nexttwodigits - units * 10) + " de mii");
								}
								i++;
							}
							break;

						case 5:
							if (units == 1) {
								saidNumber.add("o sută");
							} else if (units == 2) {
								saidNumber.add("două sute");
							} else {
								saidNumber.add(NUMBERS.get(units) + " sute");
							}
							break;

						case 6:
							if (units == 1) {
								saidNumber.add("un milion");
							} else if (units == 2) {
								saidNumber.add("două milioane");
							} else {
								saidNumber.add(NUMBERS.get(units) + " milioane");
							}
							break;
						default:
							break;
					} // end switch

					i++;
				} // end digits of number

				return String.join(" ", saidNumber);
			}
		} else if (NUMBER_RX2.matcher(number).matches()) {
			String[] parts = number.split("[,.]");
			int decimalPart = Integer.parseInt(parts[1]);

			if (decimalPart > 0) {
				String p1 = sayNumber(parts[0]) + " virgulă ";
				String decimal = parts[1];

				if (decimal.startsWith("0") || decimal.length() > 4) {
					List<String> p2List = new ArrayList<>();

					for (int i = 0; i < decimal.length(); i++) {
						String c = new String(new char[] {decimal.charAt(i)});

						p2List.add(sayNumber(c));
					}

					return p1 + String.join(" ", p2List);
				}
				else {
					return p1 + sayNumber(decimal);
				}
			}
			else {
				return sayNumber(parts[0]);
			}

		} else {
			return number;
		}
	}    
}
