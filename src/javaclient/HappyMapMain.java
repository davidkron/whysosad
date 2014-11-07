import java.awt.BorderLayout;

import javax.swing.JFrame;


public class HappyMapMain {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		 
		String URL = "http://129.16.155.25:8099/esi/esi_facade:current_happiness";
		DataCollector dc = new DataCollector (URL);
		
		
		
		HelloWorldMap map = new HelloWorldMap();
		 JFrame frame = new JFrame();
		 frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		 //frame.setLayout(new BorderLayout());
		 //frame.setSize(1024, 768);
		 frame.setExtendedState(JFrame.MAXIMIZED_BOTH);
		 frame.setVisible(true);
		 frame.add(map);
		 map.setVisible(true);
		 frame.setVisible(true);
		 map.init();
		 
	
	}

}
