require 'spec_helper'

describe CryptKeeper::Provider::PostgresPgpPublicKey do
  use_postgres

  let(:cipher_text) { '\xc1c24e03374ac5d225ffff71100bfe27156ec4de2509f29639db2820a08c79b54a5c35def273f57453c46bf2aa1e211437416afe62f97f350943519d7aa85498d98763118f5ddefa33632c8178eb1f4700dba97dadca79d9e369dc4d4b894f6fd8553185fd1ba8f4e997cbcdce71de376501eb162164668b1368743bd10f06d4ef3406faca262120f55baad2a156afe3953361cb25422a51d5fa82b55714d876ea11abe2e403b1634f7484c6db89d36d18161390b4e5531199b7cd3bd5b54a5702858d4e8cc9a9b67cedb7cb1ac00b1e9291b641e7e666a13a8a01e230506e553c0fab5a21c59f92548c16ba35b0eee42d3640ecbf55d7271ced731c5a3188b1608943b18f739614362bb52ceae7b8900abbae545bae26b8cdd8204da479b0b0fe9cb77c542c8ab20b2a149f0935929e885d1725e4e2d9406ea2bff5772e24c1d0f51b4ffd95d65995c8a0507f30f66e0e934310f603260d554d953bf5990a165c559e8ce6d0347a6ca136c6d666ea25ff751fff8952ef45aefd3aab1362799b8f67b9f05db612f6237153707757d30c009459859cb2a5133ab6062a10b22dca5c9476c7dbbd7c40a06259984a365cbca5b237b0cd2d9eac60c2dbb1ae41a362f2f6585d457a16ec221d3bf93e4fb2d2ed20ab8fe4954111292ebe1cd3a67bc180b4ea965832f1ddcf3c446bd6e686c564cbe9b467471c6d06074a5b97b1ec205ac1097a68db74b1ccb6f08405f91bf81b7449fd6cf1408f3a6b69ae0f9588e404c4389a941a1905322256afd207cdbf62df0f7824a8dbc84f9807c6ed618c2025ff1497d263a969d394d7426fc7ab85989b24a5e67b52f4e155499afef35ac43aa266d0c2afc69c20f04c0a0ee1bb949d210489d289b818be3fb1087d830c45a37ebfebb6dafb2702bd3f77006721d4bbb8366767cacd1471737be22123679cbe04f4a734b9865afbd76249da53f19219d90692f6cca1cac69fcd25a372fad325fc87f7ab1f3edcac65bc9a4cf3ba7da9cfbbabd67beba5319b984d7e855038edf9b3e5aaae5dfa8def1cfb9dd4ca0c1a9d5709f282cd4d9301adee0eada250c26668b126405b095c0e8dba69ca314f54d23501321b5c6c8bc0b25d693d6dc643b52c71f0c263e021b9a7c1a11b646175f95df6cbea5aba6210dadf9f35ef8afcf23c5a62db59ab' }

  let(:integer_cipher_text) { '\xc1c24e03374ac5d225ffff71100c008d6566bcb0e23faab9665214c2611e9e04d37cf2dc775e834bb8ec0e5b4192927c165f3fc42e667e6b2c681ffe6b87226ff02d15907f82e72019f146347e0f00e395a2ae7c2399d2f8511b290ece078ddd4de03976aac074367b588ee79536490a30e0f24d61c9a25a543834cbcbe46e27448c5afa6e11f61368ea45758993da7e2dae9ee9b8ef365f30c18c9ef8b3dfd9b307dfc65204e0c3954e00a934536712e2374a98f87e4c2b7ec069274548f2e76ae95390b0cf996b2269e9a2d4d2fd437d117ad01628eaa86a686c00fdee98efa321e47063a90a60dee36362a96136482102d8012bc6d5d966e80d39d8548233f865429ad08590d1493f3ce8bf2a7b17a53d591975e2cb3d6b81dfb25f4ea621e1b1727c8b95cd637f539390523d2b6c3a2aba1aa94057706631d5e83124b7307f53ecd01668f83d568d094e461a8cc439859ecf9964d41c2ecf36c0b46b56cdd962c387a6ba5c2eeaa4093a2550099ab1783d9a36758be2ec8effd7498bf8c8ce1bc076d7a3535b52766709dfb9900bfe3073409e705506e006f9df051d7ce83af6a47b4b6a30e9e313db8e992a3f9600160ae8f82163567e7dee06f491c66de1837ef6493f1e791186a4c9704d9eb48c48351fc1bf62e7be0a9d940013142031ae15b3ead2c96748be35ee51157ea4748ca1e4d420974e72a8cd9c5c39606557569d3a4efc4c8ff6df8cfd243be43fc0cc1ea305fc54e2e94d7ae7487c175b0e0e784ce1816872ed57f765fe4f186b0181342d9d3c207bc69cb75ab5a063d60bb67f095a593e690b54cd37f8c1448f9af9d8be384fdb7fd281c13cb235446bc17f8a1a7a1b287fe193820d457c64e329c06d143991f0a858aaa2dd7a280ba29a86ec73b1e76f290be54abfeff60bfa5e1afa7ebb9f30bf9c1bb57bc87420c460e3cd616b47ee567e2e8a1962edc26584780626fe891b79a52ced914aff5261e7da4b6a1d4fddb3ec90e18f4ff543e237cbeb7a31f2ffd147f3e135c410463ff5a92950481889680c6f860b3548d3d7326cd9f5956d4bbfdd56e1d53f51a5abeb3ae7222a48920ca16708739e809a96f9d232014ad7f53dbe68cb1bc826d8a21e2761353199fc82d854070ca10ff11bb236221422ba17f1b8c77af3801310bacb7d23bd34' }
  let(:integer_plain_text) { 1 }
  let(:plain_text)  { 'test' }

  let(:public_key) do
    IO.read(File.join(SPEC_ROOT, 'fixtures', 'public.asc'))
  end

  let(:private_key) do
    IO.read(File.join(SPEC_ROOT, 'fixtures', 'private.asc'))
  end

  subject { described_class.new key: ENCRYPTION_PASSWORD, public_key: public_key, private_key: private_key }


  specify { expect(subject.key).to eq(ENCRYPTION_PASSWORD) }

  describe "#initialize" do
    specify { expect { described_class.new }.to raise_error(ArgumentError, "Missing :key") }
  end

  describe "#encrypt" do
    context "Strings" do
      specify { expect(subject.encrypt(plain_text)).to_not eq(plain_text) }
      specify { expect(subject.encrypt(plain_text)).to_not be_empty }

      it "does not double encrypt" do
        pgp = described_class.new key: ENCRYPTION_PASSWORD, public_key: public_key
        expect(pgp.encrypt(cipher_text)).to eq(cipher_text)
      end
    end

    context "Integers" do
      specify { expect(subject.encrypt(integer_plain_text)).to_not eq(integer_plain_text) }
      specify { expect(subject.encrypt(integer_plain_text)).to_not be_empty }
    end
  end

  describe "#decrypt" do
    specify { expect(subject.decrypt(cipher_text)).to eq(plain_text) }
    specify { expect(subject.decrypt(integer_cipher_text)).to eq(integer_plain_text.to_s) }
    specify { expect(subject.decrypt(plain_text)).to eq(plain_text) }

    it "does not decrypt w/o private key" do
      pgp = described_class.new key: ENCRYPTION_PASSWORD, public_key: public_key
      expect(pgp.decrypt(cipher_text)).to eq(cipher_text)
    end
  end

  describe "#encrypted?" do
    it "returns true for encrypted strings" do
      expect(subject.encrypted?(cipher_text)).to be_truthy
    end

    it "returns false for non-encrypted strings" do
      expect(subject.encrypted?(plain_text)).to be_falsey
    end
  end
end
