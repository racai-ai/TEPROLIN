package ro.racai.reterom.tts;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Arrays;
import com.ineo.nlp.language.LanguagePipe;

/**
 * <p>
 * This class will run MLPLA as a socket-based server so that TEPROLIN is able to connect and do
 * things.
 * </p>
 * <p>
 * (C) <b>ICIA</b> 2020, Radu Ion (radu@racai.ro).
 * </p>
 * <p>
 * MLPLA is developed by Tiberiu Boroș et al.
 * (<a href="https://arxiv.org/pdf/1802.05583.pdf">paper</a>)
 * </p>
 */
public class MLPLAServer {
	private static final String MLPLA_MODEL = String.join(File.separator,
			Arrays.asList(System.getProperty("user.home"), ".teprolin", "mlpla", "models", "ro"));
	private static final String MLPLA_CONF =
			String.join(File.separator, Arrays.asList(System.getProperty("user.home"), ".teprolin",
					"mlpla", "etc", "languagepipe.conf"));
	public static final String EOT_COMMAND = "#EOT#";
	public static final String EXT_COMMAND = "#EXIT#";
	private static final boolean DEBUG = true;

	/**
	 * Will call MLPLA to process the input {@code text}. It is {@code synchronized} because it does
	 * file redirection.
	 * 
	 * @param text the input text to process.
	 * @return the TAB-separated processed text.
	 */
	private static synchronized String processText(String text) {
		// 1. Write the text to the lab.txt file
		try (BufferedWriter wrt =
				new BufferedWriter(new OutputStreamWriter(new FileOutputStream("input.txt"),
						StandardCharsets.UTF_8))) {
			wrt.write(text);
			wrt.newLine();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return null;
		}

		// 2. Preprocess the lab.txt file
		try (PrintStream redirect =
				new PrintStream(new FileOutputStream(new File("output.txt")), true, "UTF-8")) {

			PrintStream original = System.out;
			System.setOut(redirect);
			String[] args = {"--process", MLPLA_CONF, MLPLA_MODEL, "input.txt"};
			LanguagePipe.main(args);
			System.setOut(original);
		} catch (ClassNotFoundException cnfe) {
			cnfe.printStackTrace();
			return null;
		} catch (InstantiationException ie) {
			ie.printStackTrace();
			return null;
		} catch (IllegalAccessException iae) {
			iae.printStackTrace();
			return null;
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return null;
		}

		try {
			return Files.readString(new File("output.txt").toPath(), StandardCharsets.UTF_8);
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return null;
		}
	}

	public static void server(int port) {
		System.err.println("Starting MLPLA server on port " + port);
		String debugFile = "mlpla-debug-" + port + ".txt";
		
		try (BufferedWriter log = new BufferedWriter(
				new OutputStreamWriter(new FileOutputStream(new File(
						debugFile)), StandardCharsets.UTF_8))) {
			ServerSocket serverSocket = new ServerSocket(port);
			Socket clientSocket = serverSocket.accept();

			while (clientSocket != null) {
				PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true,
						StandardCharsets.UTF_8);
				BufferedReader in =
						new BufferedReader(new InputStreamReader(clientSocket.getInputStream(),
								StandardCharsets.UTF_8));
				String line = in.readLine();
				StringBuilder text = new StringBuilder();
				boolean serverExit = false;

				while (line != null) {
					if (line.equals(EXT_COMMAND)) {
						serverExit = true;

						if (DEBUG)
							log.write("Received the 'exit' command. Bye!\n");

						break;
					}
					
					if (line.equals(EOT_COMMAND)) {
						String itext = text.toString();

						if (DEBUG) {
							log.write("Going to process ====================\n");
							log.write(itext);
							log.write("End sample ==========================\n");
							log.flush();
						}

						String otext = processText(itext);

						if (DEBUG) {
							log.write("MLPLA output ========================\n");
							log.write(otext);
							log.write("End output ==========================\n");
							log.flush();
						}

						// Process the text a bit, to extract what we need.
						if (otext != null) {
							String[] olines = otext.split("\r?\n");
							StringBuilder result = new StringBuilder();

							for (String ol : olines) {
								String[] parts = ol.trim().split("\\t+");
								
								if (parts.length < 5) {
									// We do not have the same number of fields.
									// Just put something in place and go next.
									System.err.println(String.format("MLPLA error: got wrong line [%s]", ol));
									
									result.append(parts[0]);
									result.append("\t");
									result.append("_");
									result.append("\t");
									result.append("_");
									result.append("\t");
									result.append("_");
									result.append("\n");
									continue;
								}
								
								String wordform = parts[0];
								String syllables = parts[3];
								String phonetic = parts[4];
								String expanded = SayEntities.sayNumber(wordform);

								if (expanded.equals(wordform)) {
									expanded = "_";
								}
								else {
									syllables = "_";
									phonetic = "_";
								}

								result.append(wordform);
								result.append("\t");
								result.append(syllables);
								result.append("\t");
								result.append(phonetic);
								result.append("\t");
								result.append(expanded);
								result.append("\n");
							}

							out.println(result.toString());
						}

						out.println(EOT_COMMAND);
					} else if (!line.isBlank()) {
						text.append(line + "\n");
					}

					line = in.readLine();
				}

				clientSocket.close();

				if (serverExit) {
					break;
				}

				clientSocket = serverSocket.accept();
			} // end while accepting

			serverSocket.close();
			System.err.println("Exiting MLPLA server on port " + port);
		} catch (IOException ioe) {
			ioe.printStackTrace();
			System.exit(1);
		}
	}

	public static void main(String[] args) {
		if (args.length != 1) {
			System.err.println("Usage: java MLPLAServer.jar <port>");
			System.exit(1);
		}

		server(Integer.parseInt(args[0]));
	}
}
