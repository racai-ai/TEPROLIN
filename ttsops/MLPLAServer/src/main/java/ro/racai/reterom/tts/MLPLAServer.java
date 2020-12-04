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
import java.net.InetAddress;
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
	private static final String EOT_COMMAND = "#EOT#";
	private static final String EXT_COMMAND = "#EXIT#";
	private static boolean DEBUG = true;

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
		try {
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

				while (line != null) {
					if (line.equals(EXT_COMMAND)) {
						if (DEBUG)
							System.err.println("Received the 'exit' command. Bye!");

						break;
					} else if (line.equals(EOT_COMMAND)) {
						String itext = text.toString();

						if (DEBUG) {
							System.err.println("Going to process ====================");
							System.err.println(itext);
							System.err.println("End sample ==========================");
							System.err.flush();
						}

						String otext = processText(itext);

						if (DEBUG) {
							System.err.println("MLPLA output ++++++++++++++++++++++++");
							System.err.println(otext);
							System.err.println("End output ++++++++++++++++++++++++++");
							System.err.flush();
						}

						out.println(otext);
					}
					while (!line.isBlank()) {
						text.append(line + "\n");
					}

					line = in.readLine();
				}

				if (DEBUG)
					System.err
							.println("Client has closed the connection. Waiting for the next one.");

				clientSocket.close();
				clientSocket = serverSocket.accept();
			} // end while true

			serverSocket.close();
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
