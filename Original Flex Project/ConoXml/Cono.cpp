


void ConoSong::ChooseVerse()
{
    for(int i=0; i<m_Verses.length(); i++)
    {
        m_Verses[i].Mute();
    }
    
    int sel = m_pUI->GetSelectedVerse();
    
    m_Verses[sel].Mute(false);
}