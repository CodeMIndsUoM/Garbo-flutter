import 'package:flutter/material.dart';

class Forgotpassword extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.lightBlue[50],
			resizeToAvoidBottomInset: true,
			body: SafeArea(
				child: SingleChildScrollView(
					child: Padding(
						padding: const EdgeInsets.all(24.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								SizedBox(height: 20),
								// Logo
								Center(
									child: Column(
										children: [
											Icon(
												Icons.local_shipping,
												size: 60,
												color: Colors.green[700],
											),
											SizedBox(height: 4),
											Text(
												'GARBO',
												style: TextStyle(
													fontSize: 20,
													fontWeight: FontWeight.bold,
													color: Colors.green[700],
												),
											),
										],
									),
								),
								SizedBox(height: 20),
								// Back to Login
								TextButton.icon(
									onPressed: () {
										Navigator.pop(context);
									},
									icon: Icon(Icons.arrow_back, color: Colors.green[700]),
									label: Text(
										'Back to Login',
										style: TextStyle(
											color: Colors.green[700],
											fontSize: 14,
										),
									),
									style: TextButton.styleFrom(
										alignment: Alignment.centerLeft,
										padding: EdgeInsets.zero,
									),
								),
								SizedBox(height: 20),
								// Card with forgot password form
								Card(
									elevation: 4,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(12),
									),
									child: Padding(
										padding: const EdgeInsets.all(24.0),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch,
											children: [
												// Forgot Password title
												Text(
													'Forgot Password?',
													style: TextStyle(
														fontSize: 24,
														fontWeight: FontWeight.bold,
													),
												),
												SizedBox(height: 12),
												// Description
												Text(
													'No worries! Enter your username or email and we\'ll send you reset instructions.',
													style: TextStyle(
														color: Colors.grey[600],
														fontSize: 14,
													),
												),
												SizedBox(height: 30),
												// Username or Email field
												Text(
													'Username or Email',
													style: TextStyle(
														fontSize: 14,
														fontWeight: FontWeight.w500,
													),
												),
												SizedBox(height: 8),
												TextField(
													decoration: InputDecoration(
														hintText: 'Enter your username or email',
														prefixIcon: Icon(Icons.person_outline),
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(8),
														),
														filled: true,
														fillColor: Colors.white,
													),
												),
												SizedBox(height: 30),
												// Send Reset Instructions button
												ElevatedButton(
													onPressed: () {},
													style: ElevatedButton.styleFrom(
														backgroundColor: Colors.green[700],
														foregroundColor: Colors.white,
														padding: EdgeInsets.symmetric(vertical: 16),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(8),
														),
													),
													child: Text(
														'Send Reset Instructions',
														style: TextStyle(
															fontSize: 16,
															fontWeight: FontWeight.bold,
														),
													),
												),
											],
										),
									),
								),
								SizedBox(height: 30),
								// Help text
								Center(
									child: Text(
										'Need help? Contact your system administrator',
										style: TextStyle(
											fontSize: 12,
											color: Colors.grey[600],
										),
									),
								),
								SizedBox(height: 20),
							],
						),
					),
				),
			),
		);
	}
}
  
