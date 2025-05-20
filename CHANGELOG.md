Daniel Morosan, [15 Apr 2025 at 18:34:10]:
Hey Joseph!

We have taken a look together with the team. The overall state of the app is quite nice at this point, and we should be able to do a Beta Test with the community as well soon. There are still some minor things we've noticed that should probably be improved before that.

1. Wallet Name Change doesn't work as intended. Basically when you change the name of one wallet, it changes it accurately on the page where all wallets are showcased. But when you open individual wallets, you'll notice that every single wallet has the name of the latest wallet name update. On certain devices name change doesn't work at all(if the description is unclear I can record a video for you)

2. The Android Menu Buttons cover up certain parts of the app on some devices, while on others it's completely okay. Specifically the Wallet Page has the Send and Receive buttons obstructed on some devices.

3. When Sending MAS Tokens, the UX for pasting a Recipient Address is quite confusing. Basically the Application auto-pasted one of your other wallets for convenience. So you need to delete that address from the field and paste the correct one. What happens is the following:

- After pasting the correct one, now you have 2 addresses in front of you: the correct one, and one of your other wallets underneath.
- The user might be confused about what to do, and which address their tokens will be sent to
- Since Massa Mobile Wallet doesn't ask for confirmation before sending a TX, they will feel like they don't know exactly where the tokens are going.

4. You can't copy wallet addresses from the TX History Page

5. When you copy the hash from the TX History Page, it only copies the text visible on the screen, and not the entire hash. Would also be really convenient to open this in the default browser for users when they click on it.

6. You can't send any tokens besides MAS. If you swap MAS for USDC on Dusa for example, you can't do anything with your USDC. The only other thing you can do is swap them back to MAS if you want to use them. 

7. Dusa works on some devices and on others it doesn't work at all. It shows a "something went wrong screen". Swaps don't work sometimes for people that can open it, and when it does, sometimes a big grey square appears in the transaction section of the wallet.

8. On Dusa after swapping USDC to MAS, it still shows that I have USDC on my wallet, when I should have none


If something doesn't make sense, please let us know so we can reproduce the bug and record it for you

## 1.2.0
### Added
- Added dedicated view for changing wallet name.
- Added provider to handle wallet name change dynamically

### Fixed
- Wallet rename
- Fixed validation of funds.
- Fixed adddress validation.
- Fixed keyboard layout.

### Changed
- Removed creation of the first wallet automatically.
- Updated dependencies to the latest stable versions.
- Removed all unused widgets.
- Changed the font size.
- Changed the default gas fee.

## 1.1.0
### Added
- Documentation updates for better clarity.
- Added ability to select own wallet when transfering fund.
- Added ability to swap from any address and not from the default address only.
- Added help information on the settings screen.
- Added changelog file.

### Fixed
- Improved the UI elements.
- Fixed validation of funds.
- Fixed adddress validation.
- Fixed keyboard layout.

### Changed
- Removed creation of the first wallet automatically.
- Updated dependencies to the latest stable versions.
- Removed all unused widgets.
- Changed the font size.
- Changed the default gas fee.

## 1.0.0

- Initial version.
