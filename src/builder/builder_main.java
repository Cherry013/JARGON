package jargon.builder;

import java.io.*;
import java.util.*;
import org.yaml.snakeyaml.Yaml;
import java.io.FileInputStream;
import java.util.map;

public class builder_main{
	public bool create_env(){

	try{
		//Run the config script to create the environments
		ProcessBuilder pb = new ProcessBuilder("bash", "../linux/container.sh");
		ProcessBuilder pb1 = new ProcessBuilder("bash", "../linux/run_inside.sh");
		pb.inheritIO();
		Process p = pb.start();
		p.waitFor();
		pb1.inheritIO();
		Process p1 = pb1.start();
		p1.waitFor();


	}finally{
		System.out.println("Error creating the environments");
		return false;
	}
	}


	// public static bool read_creation_file(){
	// 	Yaml yaml =new Yaml();
	// 	FielInputStream file= new FileInputStream("./jargon");
	// 	Map<String, Object> data = (Map<String, Object>) yaml.load(file);
	// 	string app_name=(String) data.get()
	// }
	
}
