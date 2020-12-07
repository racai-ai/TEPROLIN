package ro.racai.reterom.tts;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertEquals;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;

/**
 * Unit test for MLPLAServer.
 */
public class ServerTest {
	@Test
	public void serverTest() {
		// 1. Run server in a separate thread
		Thread server = new Thread() {
			public void run() {
				MLPLAServer.server(12345);
			}
		};

		server.start();

		// 2. Create small client
		try (Socket client = new Socket("127.0.0.1", 12345);
				PrintWriter out =
						new PrintWriter(client.getOutputStream(), true, StandardCharsets.UTF_8);
				BufferedReader in = new BufferedReader(
						new InputStreamReader(client.getInputStream(), StandardCharsets.UTF_8));) {
			// 2.1 Send the request
			out.println("Aceasta este a 23-a propoziție de test.");
			out.println(MLPLAServer.EOT_COMMAND);

			// 2.2 Receive the answer.
			String line = in.readLine();
			List<String> lines = new ArrayList<>();

			while (line != null && !line.equals(MLPLAServer.EOT_COMMAND)) {
				line = line.trim();

				if (!line.isBlank()) {
					lines.add(line);
				}

				line = in.readLine();
			}

			assertEquals(9, lines.size());
			assertTrue(lines.get(0).endsWith("a ch e@ a s t a\t_"));
			assertTrue(lines.get(3).endsWith("douăzeci și trei"));
			// 2.3 Instruct server to quit.
			out.println(MLPLAServer.EXT_COMMAND);
			// 2.4 Join with the server thread.
			server.join();
			// Everything was OK.
		} catch (IOException | InterruptedException e) {
			assertTrue(false);
		}
	}
}
