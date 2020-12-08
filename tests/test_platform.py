from tests import tepro
from TeproAlgo import TeproAlgo

text = "La 7      minute de centrul Brasovului,  imobilul\tpropus \
    spre vanzare se adreseaza\t\tcelor care isi doresc un spatiu \
    generos de locuit.\n\nAmplasarea constructiei  si\t\tgarajul reusesc sa exploateze \
    la maxim lotul de teren de 670 mp, ce are o deschidere de 15 metri liniari.\n"
text2 = "Stia ca demonstratia o sa fie un succes."
text3 = "Instanta suprema reia astazi judecarea."
text4 = "Diabetul zaharat este un sindrom caracterizat prin valori crescute ale concentratiei \
    glucozei in sange (hiperglicemie) si dezechilibrarea metabolismului."
text5 = "Aceasta este propoziția 123 de test și nu-ți dă cu virgulă ca în 45.631."

def test_TextNorm():
    dto = tepro.pcExec(text, [TeproAlgo.getTextNormOperName()])
    
    # Spaces have been removed...
    assert dto.getText()[5] == 'm'
    assert dto.getText()[35] == 'i'

    # Tab has been removed...
    assert dto.getText()[43] == ' '
    assert dto.getText()[76] == ' '
    assert dto.getText()[77] == 'c'

    # Newlines are preserved...
    assert dto.getText()[127] == '\n'
    assert dto.getText()[128] == '\n'
   
def test_DiacRestore():
    dto = tepro.pcExec(text, [TeproAlgo.getDiacRestorationOperName()])

    # Diacs have been inserted at the proper places...
    # Brașovului
    assert dto.getText()[26] == 'ș'
    # vânzare
    assert dto.getText()[57] == 'â'
    # adresează
    assert dto.getText()[75] == 'ă'
    # își
    assert dto.getText()[88] == 'î'
    assert dto.getText()[89] == 'ș'
    # spațiu
    assert dto.getText()[105] == 'ț'

def test_TTL():
    tepro.configure(TeproAlgo.getSentenceSplittingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getTokenizationOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getPOSTaggingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getLemmatizationOperName(), TeproAlgo.algoTTL)

    dto = tepro.pcExec(text, [TeproAlgo.getChunkingOperName()])
    
    # Processed two sentences...
    assert dto.getNumberOfSentences() == 2

    # For the first sentence:
    assert dto.getSentenceTokens(0)[0].getWordForm() == 'La'
    assert dto.getSentenceTokens(0)[0].getMSD() == 'Spsa'
    assert dto.getSentenceTokens(0)[0].getLemma() == 'la'
    assert dto.getSentenceTokens(0)[1].getWordForm() == '7'
    assert dto.getSentenceTokens(0)[5].getWordForm() == 'Brașovului'
    assert dto.getSentenceTokens(0)[5].getLemma() == 'Brașov'
    assert dto.getSentenceTokens(0)[5].getMSD() == 'Npmsoy'
    assert dto.getSentenceTokens(0)[5].getChunk() == 'Pp#2,Np#2'
    assert dto.getSentenceTokens(0)[22].getWordForm() == '.'
    assert dto.getSentenceTokens(0)[22].getCTAG() == 'PERIOD'

    # For the second sentence:
    assert dto.getSentenceTokens(1)[0].getWordForm() == 'Amplasarea'
    assert dto.getSentenceTokens(1)[22].getWordForm() == 'metri'
    assert dto.getSentenceTokens(1)[22].getCTAG() == 'NPN'

def test_TTS():
    tepro.configure(TeproAlgo.getSentenceSplittingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getTokenizationOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getPOSTaggingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getLemmatizationOperName(), TeproAlgo.algoTTL)

    dto = tepro.pcExec(text5, [
        TeproAlgo.getHyphenationOperName(),
        TeproAlgo.getStressIdentificationOperName(),
        TeproAlgo.getPhoneticTranscriptionOperName(),
        TeproAlgo.getAbbreviationRewritingOperName(),
        TeproAlgo.getNumeralRewritingOperName(),
    ])

    # Processed two sentences...
    assert dto.getNumberOfSentences() == 1

    # For the first sentence:
    assert dto.getSentenceTokens(0)[3].getExpansion() == \
        'o sută douăzeci și trei'
    assert dto.getSentenceTokens(0)[0].getSyllables() == "a-'ceas-ta"
    assert dto.getSentenceTokens(0)[0].getPhonetical() == "a ch e@ a s t a"
    assert dto.getSentenceTokens(0)[11].getSyllables() == "'vir-gu-lă"
    assert dto.getSentenceTokens(0)[11].getPhonetical() == "v i r g u l @"
    assert dto.getSentenceTokens(0)[14].getExpansion() == \
        'patruzeci și cinci virgulă șase sute treizeci și unu'

def test_MWEsAndDepTransfer():
    tepro.configure(TeproAlgo.getSentenceSplittingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getTokenizationOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getPOSTaggingOperName(), TeproAlgo.algoTTL)
    tepro.configure(TeproAlgo.getLemmatizationOperName(), TeproAlgo.algoTTL)

    dto = tepro.pcFull(text2)

    assert dto.getSentenceTokens(0)[3].getWordForm() == 'o_să'
    assert dto.getSentenceTokens(0)[3].getMSD() == 'Qf'
    assert dto.getSentenceTokens(0)[3].getHead() == 7
    assert dto.getSentenceTokens(0)[3].getDepRel() == 'mark'

def test_NLPCube():
    tepro.configure(TeproAlgo.getSentenceSplittingOperName(), TeproAlgo.algoCube)
    tepro.configure(TeproAlgo.getTokenizationOperName(), TeproAlgo.algoCube)
    tepro.configure(TeproAlgo.getPOSTaggingOperName(), TeproAlgo.algoCube)
    tepro.configure(TeproAlgo.getLemmatizationOperName(), TeproAlgo.algoCube)

    dto = tepro.pcExec(text, [TeproAlgo.getDependencyParsingOperName()])
    
    # Processed two sentences...
    assert dto.getNumberOfSentences() == 2

    # Check some dependency structure...
    assert dto.getSentenceTokens(0)[7].getWordForm() == 'imobilul'
    assert dto.getSentenceTokens(0)[7].getHead() == 13
    assert dto.getSentenceTokens(0)[7].getDepRel() == 'nsubj'
    assert dto.getSentenceTokens(0)[13].getWordForm() == 'celor'
    assert dto.getSentenceTokens(0)[13].getHead() == 13
    assert dto.getSentenceTokens(0)[13].getDepRel() == 'iobj'

    assert dto.getSentenceTokens(1)[0].getWordForm() == 'Amplasarea'
    assert dto.getSentenceTokens(1)[0].getHead() == 5
    assert dto.getSentenceTokens(1)[0].getDepRel() == 'nsubj'
    assert dto.getSentenceTokens(1)[1].getWordForm() == 'construcției'
    assert dto.getSentenceTokens(1)[1].getHead() == 1
    assert dto.getSentenceTokens(1)[1].getDepRel() == 'nmod'

def test_UDPipe():
    tepro.configure(TeproAlgo.getSentenceSplittingOperName(), TeproAlgo.algoUDPipe)
    tepro.configure(TeproAlgo.getTokenizationOperName(), TeproAlgo.algoUDPipe)
    tepro.configure(TeproAlgo.getPOSTaggingOperName(), TeproAlgo.algoUDPipe)
    tepro.configure(TeproAlgo.getLemmatizationOperName(), TeproAlgo.algoUDPipe)

    dto = tepro.pcExec(text4, [TeproAlgo.getDependencyParsingOperName()])
    
    # Processed two sentences...
    assert dto.getNumberOfSentences() == 1
    assert len(dto.getSentenceTokens(0)) == 21

    # Check some dependency structure...
    assert dto.getSentenceTokens(0)[5].getHead() == 5
    assert dto.getSentenceTokens(0)[5].getDepRel() == 'acl'
    assert dto.getSentenceTokens(0)[10].getWordForm() == 'concentrației'
    assert dto.getSentenceTokens(0)[10].getLemma() == 'concentrație'
    assert dto.getSentenceTokens(0)[10].getCTAG() == 'NOUN'
    assert dto.getSentenceTokens(0)[10].getMSD() == 'Ncfsoy'
    assert dto.getSentenceTokens(0)[10].getHead() == 8
    assert dto.getSentenceTokens(0)[10].getDepRel() == 'nmod'
    assert dto.getSentenceTokens(0)[17].getWordForm() == 'și'

def test_NEROps():
    dto = tepro.pcExec(text3, [TeproAlgo.getNamedEntityRecognitionOperName()])

    # Check NER annotations
    assert dto.getSentenceTokens(0)[0].getNER() == 'ORG'
    assert dto.getSentenceTokens(0)[1].getNER() == 'ORG'
    assert dto.getSentenceTokens(0)[3].getNER() == 'TIME'

def test_BioNEROps():
    dto = tepro.pcExec(text4, [TeproAlgo.getBiomedicalNamedEntityRecognitionOperName()])

    # Check BioNER annotations
    assert dto.getSentenceTokens(0)[0].getBioNER() == 'B-DISO'
    assert dto.getSentenceTokens(0)[1].getBioNER() == 'I-DISO'
    assert dto.getSentenceTokens(0)[4].getBioNER() == 'B-DISO'
    assert dto.getSentenceTokens(0)[11].getBioNER() == 'B-CHEM'
    assert dto.getSentenceTokens(0)[13].getBioNER() == 'B-ANAT'
